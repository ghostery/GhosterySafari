//
// HelpViewController
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

class HelpViewController: NSViewController {
	
	@IBOutlet weak var helpText: NSTextField!
	@IBOutlet weak var supportBtn: NSButton!
	@IBOutlet weak var productsBtn: NSButton!
	@IBOutlet weak var blogBtn: NSButton!
	@IBOutlet weak var faqBtn: NSButton!
	
	/// Action taken when the help links are clicked
	/// - Parameter sender: The clicked link
	@IBAction func HelpLinkClicked(_ sender: NSButton) {
		if sender == supportBtn {
			openURL("https://www.ghostery.com/support/")
		} else if sender == productsBtn {
			openURL("https://www.ghostery.com/products/")
		} else if sender == blogBtn {
			openURL("https://www.ghostery.com/blog/")
		} else if sender == faqBtn {
			openURL("https://www.ghostery.com/faqs/product/ghostery-lite/")
		}
	}
	
	/// Called after the view controller’s view has been loaded into memory.
	override func viewDidLoad() {
		super.viewDidLoad()
		initComponents()
	}
	
	/// Open the specified URL
	/// - Parameter urlString: A URL specifying the location to open
	private func openURL(_ urlString: String) {
		if let url = URL(string: urlString) {
			NSWorkspace.shared.open(url)
		}
	}
	
	/// Set formatting for view text and buttons
	private func initComponents() {
		self.helpText.attributedStringValue = self.helpText.stringValue.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: NSColor.panelTextColor(), isUnderline: false, lineSpacing: 3)
		supportBtn.attributedTitle = supportBtn.title.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 14.0, fontColor: NSColor(named: "linkColor") ?? NSColor.blue, isUnderline: true)
		productsBtn.attributedTitle = productsBtn.title.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 14.0, fontColor: NSColor(named: "linkColor") ?? NSColor.blue, isUnderline: true)
		blogBtn.attributedTitle = blogBtn.title.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 14.0, fontColor: NSColor(named: "linkColor") ?? NSColor.blue, isUnderline: true)
		faqBtn.attributedTitle = faqBtn.title.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 14.0, fontColor: NSColor(named: "linkColor") ?? NSColor.blue, isUnderline: true)
	}
}

