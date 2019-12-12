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

import Cocoa

extension NSApplication {
	/// Action taken when the default configuration radio is selected
	/// - Parameter sender: The default configuration radio option
	@IBAction func defaultConfigSelected(_ sender: NSMenuItem) {
		Utils.shared.logger("Changing to default blocking configuration")
		GhosteryApplication.shared.switchToDefaultBlocking()
		if let m = sender.parent?.submenu {
			m.items[1].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}
	
	/// Action taken when the custom configuration radio is selected
	/// - Parameter sender: The custom configuration radio option
	@IBAction func customConfigSelected(_ sender: NSMenuItem) {
		Utils.shared.logger("Changing to custom blocking configuration")
		GhosteryApplication.shared.switchToCustomBlocking()
		if let m = sender.parent?.submenu {
			m.items[0].state = NSControl.StateValue(rawValue: 0)
			sender.state = NSControl.StateValue(rawValue: 1)
		}
	}
	
	/// Action taken when the support link is clicked
	/// - Parameter sender: The support link
	@IBAction func showGhosteryHelp(_ sender: NSMenuItem) {
		if let url = URL(string: "https://www.ghostery.com/support/") {
			NSWorkspace.shared.open(url)
		}
	}
}
