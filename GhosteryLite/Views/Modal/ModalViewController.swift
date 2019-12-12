//
// ModalViewController
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

class ModalViewController: NSViewController {
	
	var delegate: ModalViewControllerDelegate? = nil
	
	@IBOutlet weak var enableGhosteryLiteText: NSTextField!
	@IBOutlet weak var enableGhosteryLiteBtn: NSButton!
	@IBOutlet weak var skipButton: NSButton!
	
	/// Action taken when the Enable button is clicked
	/// - Parameter sender: Enable button
	@IBAction func enableGhosteryLite(_ sender: NSButton) {
		self.delegate?.hideSafariExtensionPopOver()
		// TODO: Needs to be refactored
		HomeViewController.showSafariPreferencesForExtension()
	}
	
	/// Action taken when the skip button is pressed
	/// - Parameter sender: The skip button
	@IBAction func skip(_ sender: NSButton) {
		self.delegate?.hideSafariExtensionPopOver()
	}
	
	/// Called after the view controller’s view has been loaded into memory
	override func viewDidLoad() {
		super.viewDidLoad()
		initComponents()
	}
	
	/// Set formatting for view text and buttons
	private func initComponents() {
		enableGhosteryLiteBtn.attributedTitle = enableGhosteryLiteBtn.title.attributedString(withTextAlignment: .center, fontName: "Roboto-Medium", fontSize: 14.0, fontColor: NSColor.white, isUnderline: true)
		skipButton.attributedTitle = skipButton.title.attributedString(withTextAlignment: .center, fontName: "Roboto-Regular", fontSize: 14.0, fontColor: NSColor(rgb: 0x4a4a4a), isUnderline: true)
	}
}
