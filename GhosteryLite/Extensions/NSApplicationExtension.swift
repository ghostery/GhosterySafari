//
// NSApplicationExtension
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

extension NSApplication {
	@IBAction func defaultConfigSelected(_ sender: NSMenuItem) {
		print("Default")
		ContentBlockerManager.shared.switchToDefault()
		if let m = sender.parent?.submenu {
			m.items[1].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}
	
	@IBAction func customConfigSelected(_ sender: NSMenuItem) {
		print("Custom")
		ContentBlockerManager.shared.switchToCustom()
		if let m = sender.parent?.submenu {
			m.items[0].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}
	
	@IBAction func showGhosteryHelp(_ sender: NSMenuItem) {
		if let url = URL(string: "https://www.ghostery.com/support/") {
			NSWorkspace.shared.open(url)
		}
	}
}
