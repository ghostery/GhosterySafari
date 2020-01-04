//
// GhosteryApplication
// GhosteryLite
//
// Ghostery Lite for Safari
// https://www.ghostery.com/
//
// Copyright 2019 Ghostery, Inc. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0
//

import Foundation
import SafariServices

/// Manages GhosteryLite application state between targets. Set paused/resumed, trust/untrust,
/// change block list settings, reload Content Blockers
class GhosteryApplication {
	
	static let shared = GhosteryApplication()
	private var paused: Bool = false
	
	deinit {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.PauseNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.ResumeNotificationName, object: Constants.SafariExtensionID)
	}
	
	/// Create notification subscriptions
	func subscribeForNotifications() {
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.pauseNotification), name: Constants.PauseNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.resumeNotification), name: Constants.ResumeNotificationName, object: Constants.SafariExtensionID)
	}
	
	/// Pause GhosteryLite
	func pause() {
		self.paused = true
		self.reloadContentBlockers()
	}
	
	/// Resume GhosteryLite
	func resume() {
		self.paused = false
		self.reloadContentBlockers()
	}
	
	/// Check to see if GhosteryList is paused
	func isPaused() -> Bool {
		return self.paused
	}
	
	/// Notification handler from a pause action
	@objc func pauseNotification() {
		self.paused = true
	}
	
	/// Notification handler for a resume action
	@objc func resumeNotification() {
		self.paused = false
	}
	
	/// Enable the default blocking configuration
	func switchToDefaultBlocking() {
		BlockingConfiguration.shared.updateConfigType(type: .defaultBlocking)
		self.reloadContentBlockers()
	}
	
	/// Enable the custom blocking configuration
	func switchToCustomBlocking() {
		BlockingConfiguration.shared.updateConfigType(type: .customBlocking)
		self.reloadContentBlockers()
	}
	
	/// Are we using the default blocking configuration
	func isDefaultBlockingEnabled() -> Bool {
		let cfgType = BlockingConfiguration.shared.getConfigType()
		return cfgType == BlockingConfiguration.ConfigurationType.defaultBlocking.rawValue
	}
	
	/// Add a domain to the whitelist
	/// - Parameter domain: Domain URL
	func trustDomain(domain: String) {
		TrustedSite.shared.addDomain(domain)
		WhiteList.shared.add(domain, completion: {
			self.reloadContentBlockers()
		})
	}
	
	/// Remove a domain from the whitelist
	/// - Parameter domain: Domain URL
	func untrustDomain(domain: String) {
		TrustedSite.shared.removeDomain(domain)
		WhiteList.shared.remove(domain, completion: {
			self.reloadContentBlockers()
		})
	}
	
	/// Is the domain in the whitelist?
	/// - Parameter domain: Domain URL
	func isDomainTrusted(domain: String) -> Bool {
		return TrustedSite.shared.isSiteTrusted(domain)
	}
	
	/// Check for updated block lists. Called from AppDelegate applicationDidFinishLaunching()
	func checkForUpdatedBlockLists() {
		BlockLists.shared.updateBlockLists(done: { (updated) in
			// Did we download a new block list version?
			if updated {
				// Generate the new block list and reload the Content Blocker
				self.reloadContentBlockers()
			}
		})
	}
	
	/// Reload all active content blockers. Checks if the user is using the default or custom block list config and triggers updateAndReloadBlockList(), which generates
	/// the new block list as needed.
	func reloadContentBlockers() {
		if self.isPaused() {
			self.loadDummyBlockList()
		} else {
			if self.isDefaultBlockingEnabled() {
				self.loadDefaultBlockList()
			} else {
				self.loadCustomBlockList()
			}
			// Refresh Cliqz content blockers
			// TODO: We should ignore this on blocking configuration changes (custom vs default) and only refresh on resume, trust and restrict
			self.updateAndReloadBlockList(fileNames: [Constants.CliqzCosmeticList], contentBlocker: Constants.ContentBlockerLists.cosmetic)
			self.updateAndReloadBlockList(fileNames: [Constants.CliqzNetworkList], contentBlocker: Constants.ContentBlockerLists.network)
		}
	}
	
	/// Load an empty block list file into each of the Content Blockers.  Used during pause and site whitelist scenarios
	private func loadDummyBlockList() {
		Utils.logger("Loading dummy block lists for all content blockers...")
		self.updateAndReloadBlockList(fileNames: [Constants.EmptyRulesList], contentBlocker: Constants.ContentBlockerLists.standard)
		self.updateAndReloadBlockList(fileNames: [Constants.EmptyRulesList], contentBlocker: Constants.ContentBlockerLists.cosmetic)
		self.updateAndReloadBlockList(fileNames: [Constants.EmptyRulesList], contentBlocker: Constants.ContentBlockerLists.network)
	}
	
	/// Load the default Ghostery block list file consisting of the default categories only. Used by the standard content blocker.
	private func loadDefaultBlockList() {
		Utils.logger("Loading default Ghostery block list categories for \(Constants.SafariContentBlockerID)")
		var fileNames = [String]()
		// Ghostery default categories
		for index in BlockingConfiguration.shared.defaultBlockedCategories() {
			fileNames.append(index.fileName())
		}
		// Trigger a Content Blocker reload
		self.updateAndReloadBlockList(fileNames: fileNames, contentBlocker: Constants.ContentBlockerLists.standard)
	}
	
	/// Load the full Ghostery block list (all categories). Used by the standard content blocker.
	private func loadFullBlockList() {
		Utils.logger("Loading full Ghostery block list for \(Constants.SafariContentBlockerID)")
		self.updateAndReloadBlockList(fileNames: [Constants.GhosteryBlockList], contentBlocker: Constants.ContentBlockerLists.standard)
	}
	
	/// Load a custom Ghostery block list file based on user selected categories. Used by the standard content blocker.
	private func loadCustomBlockList() {
		// Get the blockedCategories from CoreData
		if let cats = BlockingConfiguration.shared.getBlockedCategories() {
			var fileNames = [String]()
			// No categories selected, load empty block list
			if cats.count == 0 {
				self.loadDummyBlockList()
				return
			}
			// All categories selected, load full block list
			if cats.count == Categories.allCategoriesCount() {
				self.loadFullBlockList()
				return
			}
			// Load selected categories
			for index in cats {
				if let cat = Categories(rawValue: index) {
					fileNames.append(cat.fileName())
				}
			}
			
			Utils.logger("Loading custom Ghostery block list categories for \(Constants.SafariContentBlockerID)")
			
			// Trigger a Content Blocker reload
			self.updateAndReloadBlockList(fileNames: fileNames, contentBlocker: Constants.ContentBlockerLists.standard)
		}
	}

	/// Trigger a Content Blocker reload of specified block list files,  for the given content blocker
	/// - Parameter fileNames: The block list json filenames to be loaded
	/// - Parameter contentBlocker: The content blocker that should be reloaded
	private func updateAndReloadBlockList(fileNames: [String], contentBlocker: Constants.ContentBlockerLists) {
		Utils.logger("Generating new block list for \(contentBlocker.getID())...")
		BlockLists.shared.generateCurrentBlockList(files: fileNames, blockListFile: contentBlocker.rawValue) {
			self.reloadContentBlocker(withIdentifier: contentBlocker.getID())
		}
	}

	/// Reload the Content Blocker extension
	/// - Parameter identifier: The bundle ID of the Content Blocker to reload
	private func reloadContentBlocker(withIdentifier identifier: String) {
		Utils.logger("Reloading \(identifier)...")
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier, completionHandler: { (error) in
			if let error = error as NSError? {
				Utils.logger("Reloading \(identifier) failed with error \(error), \(error.userInfo)")
			} else {
				Utils.logger("Successfully reloaded \(identifier)!")
			}
		})
	}
}
