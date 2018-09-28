//
//  AppDelegate.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var mainWindow: NSWindow?

	@IBOutlet weak var protectionConfigMenu: NSMenuItem!

	func applicationDidBecomeActive(_ notification: Notification) {
		self.updateConfigState()
		TelemetryManager.shared.sendSignal(.active)
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		self.updateConfigState()
		TelemetryManager.shared.sendSignal(.install)
		TelemetryManager.shared.sendSignal(.upgrade)
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// TODO: Refactor UserDefaults calls in sentralized Pref class
		UserDefaults.standard.set(50, forKey: "NSInitialToolTipDelay")
		UserDefaults.standard.synchronize()
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateConfigState),
															name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateConfigState),
															name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
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
			if AntiTrackingManager.shared.isDefaultConfigEnabled() {
				m.items[0].state = NSControl.StateValue(rawValue: 1)
				m.items[1].state = NSControl.StateValue(rawValue: 0)
			} else {
				m.items[0].state = NSControl.StateValue(rawValue: 0)
				m.items[1].state = NSControl.StateValue(rawValue: 1)
			}
		}
	}
}

extension NSApplication {
	@IBAction func defaultConfigSelected(_ sender: NSMenuItem) {
		print("Default")
		AntiTrackingManager.shared.switchToDefault()
		if let m = sender.parent?.submenu {
			m.items[1].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func customConfigSelected(_ sender: NSMenuItem) {
		print("Custom")
		AntiTrackingManager.shared.switchToCustom()
		if let m = sender.parent?.submenu {
			m.items[0].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func showGhosteryHelp(_ sender: NSMenuItem) {
		if let url = URL(string: "https://ghostery.zendesk.com/hc/en-us") {
			NSWorkspace.shared.open(url)
		}
	}
}
