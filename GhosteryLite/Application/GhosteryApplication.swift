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
/// change block list settings, reload Content Blocker
class GhosteryApplication {
	
	static let shared = GhosteryApplication()
	private var paused: Bool = false
	
	init() {}
	
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
	
	/// Notification handler for a trust site action
	func trustSiteNotification() {
		if let d = Preferences.getGlobalPreference(key: "domain") as? String {
			self.trustDomain(domain: d)
			self.loadDummyBlockList()
		}
	}
	
	/// Notification handler for an untrust site action
	func untrustSiteNotification() {
		if let d = Preferences.getGlobalPreference(key: "domain") as? String {
			self.untrustDomain(domain: d)
			self.reloadContentBlockers()
		}
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
		}
	}
	
	/// Load the full block list (all categories)
	private func loadFullBlockList() {
		self.updateAndReloadBlockList(fileNames: ["safariContentBlocker"], folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Load the default block list file consisting of the default categories only
	private func loadDefaultBlockList() {
		var fileNames = [String]()
		// Ghostery default categories
		for index in BlockingConfiguration.shared.defaultBlockedCategories() {
			fileNames.append(index.fileName())
		}
		// Trigger a Content Blocker reload
		self.updateAndReloadBlockList(fileNames: fileNames, folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Load a custom block list file based on user selected categories
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
			// Trigger a Content Blocker reload
			self.updateAndReloadBlockList(fileNames: fileNames, folderName: Constants.BlockListAssetsFolder)
		}
	}

	/// Load an empty block list file.  Used during  pause and site whitelist scenarios
	private func loadDummyBlockList() {
		self.updateAndReloadBlockList(fileNames: ["emptyRules"], folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Trigger a Content Blocker reload
	/// - Parameter fileNames: The block list json filenames to be loaded
	/// - Parameter folderName: The name of the folder where the json files are located on disk
	private func updateAndReloadBlockList(fileNames: [String], folderName: String) {
		Utils.shared.logger("Generating new block list...")
		BlockLists.shared.generateCurrentBlockList(files: fileNames, folderName: folderName) {
			self.reloadContentBlocker(withIdentifier: Constants.SafariContentBlockerID)
		}
	}

	
	/// Reload the Content Blocker extension
	/// - Parameter identifier: The bundle ID of the Content Blocker to reload
	private func reloadContentBlocker(withIdentifier identifier: String) {
		Utils.shared.logger("Reloading Content Blocker...")
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier, completionHandler: { (error) in
			if error != nil {
				Utils.shared.logger("Reloading Content Blocker failed with error \(String(describing: error))")
			} else {
				Utils.shared.logger("Successfully reloaded Content Blocker!")
			}
		})
	}
}
