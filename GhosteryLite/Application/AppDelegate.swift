//
// AppDelegate
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

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	var mainWindow: NSWindow?
	
	/// Core Data: The persistent container for the application
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "GhosteryLite")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				fatalError("AppDelegate.persistentContainer error: \(error)")
			}
		})
		return container
	}()
	
	@IBOutlet weak var protectionConfigMenu: NSMenuItem!
	
	/// Sent by the default notification center immediately before the application object is initialized.
	func applicationWillFinishLaunching(_ notification: Notification) {
		self.updateConfigState()
		Telemetry.shared.sendSignal(.install)
		Telemetry.shared.sendSignal(.upgrade)
	}
	
	/// Sent by the default notification center after the application has been launched and initialized but before it has received its first event.
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Utils.shared.logger("Ghostery Lite launched successfully")
		// Set prefs
		Preferences.setAppPreference(key: "NSInitialToolTipDelay", value: 50)
		// Create notification listeners
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
		// Handle first launch bootstrapping
		if Preferences.isAppFirstLaunch() {
			self.handleInitialLaunch()
		}
		// Check for new Block Lists on CDN
		GhosteryApplication.shared.checkForUpdatedBlockLists()
	}
	
	/// Sent by the default notification center immediately after the application becomes active.
	func applicationDidBecomeActive(_ notification: Notification) {
		self.updateConfigState()
		Telemetry.shared.sendSignal(.active, source: 3)
	}
	
	/// Sent by the default notification center immediately before the application terminates.
	func applicationWillTerminate(_ aNotification: Notification) {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	/// Invoked when the user closes the last window the application has open.
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	/// Sent by the application to the delegate prior to default behavior to reopen (rapp) AppleEvents.
	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if !flag {
			mainWindow?.makeKeyAndOrderFront(self)
		}
		return true
	}
	
	/// Update the blocking config selectors
	@objc private func updateConfigState() {
		if let menu = self.protectionConfigMenu?.submenu {
			if GhosteryApplication.shared.isDefaultBlockingEnabled() {
				menu.items[0].state = NSControl.StateValue(rawValue: 1)
				menu.items[1].state = NSControl.StateValue(rawValue: 0)
			} else {
				menu.items[0].state = NSControl.StateValue(rawValue: 0)
				menu.items[1].state = NSControl.StateValue(rawValue: 1)
			}
		}
	}
	
	/// Provision the application preferences and resources on a fresh installation
	private func handleInitialLaunch(){
		Utils.shared.logger("Initial launch detected")
		// Copy block list assets to Group Containers
		guard let resources = Bundle.main.resourceURL?.appendingPathComponent(Constants.BlockListAssetsFolder, isDirectory: true).path,
			let groupStorageFolder = Constants.AssetsFolderURL?.path else {
				Utils.shared.logger("Error copying BlockListAssets to Group Containers")
				return
		}
		// Make sure the BlockListAssets folder hasn't already been migrated
		if !FileManager.default.fileExists(atPath: groupStorageFolder) {
			FileManager.default.copyFiles(resources, groupStorageFolder)
		}
		
		// Check the version of the Ghostery block list that shipped with the application. Save the version
		// to Preferences to prevent an unnecessary update check
		struct versionData: Decodable {
			var safariContentBlockerVersion: Int
		}
		if let url = Bundle.main.url(forResource: "version", withExtension: "json", subdirectory: Constants.BlockListAssetsFolder) { // Fetch version from app bundle
			do {
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let jsonData = try decoder.decode(versionData.self, from: data)
				Utils.shared.logger("safariContentBlockerVersion is \(jsonData.safariContentBlockerVersion)")
				Preferences.setGlobalPreference(key: Constants.GhosteryBlockListVersionKey, value: jsonData.safariContentBlockerVersion)
			} catch {
				Utils.shared.logger("Error getting safariContentBlockerVersion \(error)")
			}
		}
	}
}
