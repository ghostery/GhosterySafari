//
//  WindowController.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/21/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import RealmSwift

class WindowController: NSWindowController {
	
	override func windowWillLoad() {
		super.windowWillLoad()
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		let appDelegate = NSApplication.shared.delegate as? AppDelegate
		appDelegate?.mainWindow = self.window
	}

}
