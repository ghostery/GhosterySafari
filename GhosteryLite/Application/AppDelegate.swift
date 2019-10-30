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
	
	@IBOutlet weak var protectionConfigMenu: NSMenuItem!
	
	func applicationDidBecomeActive(_ notification: Notification) {
		self.updateConfigState()
		TelemetryManager.shared.sendSignal(.active, ghostrank: 3)
	}
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		self.updateConfigState()
		TelemetryManager.shared.sendSignal(.install)
		TelemetryManager.shared.sendSignal(.upgrade)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		print("AppDelegate.applicationDidFinishLaunching: Ghostery Lite launched successfully")
		// TODO: Refactor UserDefaults calls in centralized Pref class
		UserDefaults.standard.set(50, forKey: "NSInitialToolTipDelay")
		UserDefaults.standard.synchronize()
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateConfigState), name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
		// Check for new Block Lists on CDN
		ContentBlockerManager.shared.updateBlockLists()
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if !flag {
			mainWindow?.makeKeyAndOrderFront(self)
		}
		return true
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	@objc
	func updateConfigState() {
		if let m = self.protectionConfigMenu?.submenu {
			if ContentBlockerManager.shared.isDefaultConfigEnabled() {
				m.items[0].state = NSControl.StateValue(rawValue: 1)
				m.items[1].state = NSControl.StateValue(rawValue: 0)
			} else {
				m.items[0].state = NSControl.StateValue(rawValue: 0)
				m.items[1].state = NSControl.StateValue(rawValue: 1)
			}
		}
	}
}
