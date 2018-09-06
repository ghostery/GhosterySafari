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
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		self.updateConfigState()
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
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
}
