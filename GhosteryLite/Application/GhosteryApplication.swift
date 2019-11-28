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
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.PauseNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.ResumeNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	/// Create notification subscriptions
	func subscribeForNotifications() {
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.pauseNotification), name: Constants.PauseNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.resumeNotification), name: Constants.ResumeNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	/// Pause GhosteryLite
	func pause() {
		self.paused = true
		self.reloadContentBlocker()
	}
	
	/// Resume GhosteryLite
	func resume() {
		self.paused = false
		self.reloadContentBlocker()
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
		BlockingConfig.shared.updateConfigType(type: .defaultBlocking)
		self.reloadContentBlocker()
	}
	
	/// Enable the custom blocking configuration
	func switchToCustomBlocking() {
		BlockingConfig.shared.updateConfigType(type: .customBlocking)
		self.reloadContentBlocker()
	}
	
	/// Are we using the default blocking configuration
	func isDefaultBlockingEnabled() -> Bool {
		let cfgType = BlockingConfig.shared.getConfigType()
		return cfgType == BlockingConfig.ConfigurationType.defaultBlocking.rawValue
	}
	
	/// Add a domain to the whitelist
	/// - Parameter domain: Domain URL
	func trustDomain(domain: String) {
		TrustedSitesDataSource.shared.addDomain(domain)
		WhiteList.shared.add(domain, completion: {
			self.reloadContentBlocker()
		})
	}
	
	/// Remove a domain from the whitelist
	/// - Parameter domain: Domain URL
	func untrustDomain(domain: String) {
		TrustedSitesDataSource.shared.removeDomain(domain)
		WhiteList.shared.remove(domain, completion: {
			self.reloadContentBlocker()
		})
	}
	
	/// Is the domain in the whitelist?
	/// - Parameter domain: Domain URL
	func isTrustedDomain(domain: String) -> Bool {
		return TrustedSitesDataSource.shared.isTrusted(domain)
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
			self.reloadContentBlocker()
		}
	}
	
	/// Check for updated block lists. Called from AppDelegate applicationDidFinishLaunching()
	func checkForUpdatedBlockLists() {
		BlockLists.shared.updateBlockLists(done: { (updated) in
			// Did we download a new block list version?
			if updated {
				// Generate the new block list and reload the Content Blocker
				self.reloadContentBlocker()
			}
		})
	}
	
	/// Checks if the user is using the default or custom block list config. Triggers self.updateAndReloadBlockList(), which generates
	/// the new block list as needed and reloads the Content Blocker
	func reloadContentBlocker() {
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
	
	/// Load a custom block list file based on user selected categories
	private func loadCustomBlockList() {
		// Get the blockedCategories from CoreData
		if let cats = BlockingConfig.shared.getBlockedCategories() {
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
	
	/// Load the default block list file consisting of the default categories only
	private func loadDefaultBlockList() {
		var fileNames = [String]()
		for index in BlockingConfig.shared.defaultBlockedCategories() {
			fileNames.append(index.fileName())
		}
		// Trigger a Content Blocker reload
		self.updateAndReloadBlockList(fileNames: fileNames, folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Load an empty block list file.  Used during  pause and site whitelist scenarios
	private func loadDummyBlockList() {
		self.updateAndReloadBlockList(fileNames: ["emptyRules"], folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Load the full block list (all categories)
	private func loadFullBlockList() {
		self.updateAndReloadBlockList(fileNames: ["safariContentBlocker", "cliqzNetworkList", "cliqzCosmeticList"], folderName: Constants.BlockListAssetsFolder)
	}
	
	/// Trigger a Content Blocker reload
	/// - Parameter fileNames: The block list json filenames to be loaded
	/// - Parameter folderName: The name of the folder where the json files are located on disk
	private func updateAndReloadBlockList(fileNames: [String], folderName: String) {
		print("GhosteryApplication.updateAndReloadBlockList: Generating new block list...")
		BlockLists.shared.generateCurrentBlockList(files: fileNames, folderName: folderName) {
			print("GhosteryApplication.updateAndReloadBlockList: Build phase complete")
			self.reloadCBExtension()
		}
	}
	
	/// Reload the Content Blocker extension
	private func reloadCBExtension() {
		print("GhosteryApplication.reloadCBExtension: Reloading Content Blocker...")
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: Constants.SafariContentBlockerID, completionHandler: { (error) in
			if error != nil {
				print("GhosteryApplication.reloadCBExtension: Reloading Content Blocker failed with error \(String(describing: error))")
			} else {
				print("GhosteryApplication.reloadCBExtension: Successfully reloaded Content Blocker!")
			}
		})
	}
}
