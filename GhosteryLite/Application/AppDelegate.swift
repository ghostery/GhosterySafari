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
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	var mainWindow: NSWindow?
	
	@IBOutlet weak var protectionConfigMenu: NSMenuItem!
	
	/// Sent by the default notification center immediately before the application object is initialized.
	func applicationWillFinishLaunching(_ notification: Notification) {
		self.updateConfigState()
	}
	
	/// Sent by the default notification center after the application has been launched and initialized but before it has received its first event.
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Utils.logger("Ghostery Lite launched successfully")
		// Set prefs
		Preferences.setAppPreference(key: "NSInitialToolTipDelay", value: 50)
		// Create notification listeners
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToCustomNotificationName, object: Constants.SafariExtensionID)
		// Handle new installation
		if Preferences.isNewInstall() {
			self.handleInitialLaunch()
			Telemetry.shared.sendSignal(.install)
		}
		// Handle application upgrade {
		if Preferences.isUpgrade() {
			self.handleApplicationUpgrade()
			Telemetry.shared.sendSignal(.upgrade)
		}
		// Check for new Block Lists on CDN
		GhosteryApplication.shared.checkForUpdatedBlockLists()
	}
	
	/// Sent by the default notification center immediately after the application becomes active.
	func applicationDidBecomeActive(_ notification: Notification) {
		self.updateConfigState()
		Telemetry.shared.sendSignal(.active, source: TelemetryService.PingSource.ghosteryLiteApplication)
	}
	
	/// Sent by the default notification center immediately before the application terminates.
	func applicationWillTerminate(_ aNotification: Notification) {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToCustomNotificationName, object: Constants.SafariExtensionID)
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
		Utils.logger("Initial launch detected")
		// Copy block list assets to Group Containers
		guard let resources = Bundle.main.resourceURL?.appendingPathComponent(Constants.BlockListAssetsFolder, isDirectory: true).path,
			let groupStorageFolder = Constants.AssetsFolderURL?.path else {
				Utils.logger("Error copying BlockListAssets to Group Containers")
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
				Utils.logger("\(Constants.GhosteryBlockListVersionKey) is \(jsonData.safariContentBlockerVersion)")
				Preferences.setGlobalPreference(key: Constants.GhosteryBlockListVersionKey, value: jsonData.safariContentBlockerVersion)
			} catch {
				Utils.logger("Error getting \(Constants.GhosteryBlockListVersionKey): \(error)")
			}
		}
	}
	
	/// Run application version upgrade logic
	private func handleApplicationUpgrade() {
		Utils.logger("Upgrade detected")
		
		// Migrate Ghostery Lite v1.0.0 settings from Realm to CoreData
		if !Preferences.getAppPreferenceBool(key: Constants.coreDataMigrationCompleted) {
			self.handleCoreDataMigration()
		}
	}
	
	/// Migrate legacy user settings from Realm to CoreData
	private func handleCoreDataMigration() {
		self.configureRealm()
		let realm = try! Realm()
		
		// Migrate Trusted Sites from Realm to CoreData
		let sites = realm.objects(TrustedSiteObject.self)
		for site in sites {
			if let name = site.name {
				TrustedSite.shared.addDomain(name)
			}
		}
		
		// Migrate Blocking Config from Realm to CoreData
		let config = realm.objects(GlobalConfigObject.self)
		for cfg in config {
			if let val = cfg.configType.value {
				// Update the blocking config. Note: We have to invert the blocking config value, because previously 0 = custom, 1 = default
				BlockingConfiguration.shared.updateConfigType(type: BlockingConfiguration.ConfigurationType(rawValue: 1 - val) ?? BlockingConfiguration.ConfigurationType.defaultBlocking)
			}
			if cfg.blockedCategories.count > 0 {
				var cats = Categories.allCategories()
				// Block the blocked categories
				for cat in cfg.blockedCategories {
					if let c = Categories(rawValue: cat) {
						BlockingConfiguration.shared.updateBlockedCategory(category: c, blocked: true)
						// Remove the value from cats array, so that we can unblock whichever categories are left over
						if let index = cats.firstIndex(of: c) {
							cats.remove(at: index)
						}
					}
				}
				// Unblock the allowed categories
				for cat in cats {
					BlockingConfiguration.shared.updateBlockedCategory(category: cat, blocked: false)
				}
			}
		}
		
		Preferences.setAppPreference(key: Constants.coreDataMigrationCompleted, value: true)
	}
	
	/// Handle Realm configuration
	private func configureRealm() {
		let config = Realm.Configuration(
			schemaVersion: 1,
			migrationBlock: { migration, oldSchemaVersion in
				if (oldSchemaVersion < 1) {}
		}
		)
		Realm.Configuration.defaultConfiguration = config
		let realmPath = Constants.GroupStorageFolderURL?.appendingPathComponent("db.realm")
		Realm.Configuration.defaultConfiguration.fileURL = realmPath
	}
}
