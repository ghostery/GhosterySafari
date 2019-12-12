//
// WindowController
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

class WindowController: NSWindowController {
	
	/// Sent before the window owned by the receiver is loaded
	override func windowWillLoad() {
		super.windowWillLoad()
	}
	
	/// Sent after the window owned by the receiver has been loaded
	override func windowDidLoad() {
		super.windowDidLoad()
		let appDelegate = NSApplication.shared.delegate as? AppDelegate
		appDelegate?.mainWindow = self.window
	}
}
