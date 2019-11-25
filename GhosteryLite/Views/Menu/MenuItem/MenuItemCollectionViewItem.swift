//
// MenuItemCollectionViewItem
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

class MenuItemCollectionViewItem: NSCollectionViewItem {
	
	private var item: MenuItem? = nil
	private var indexPath: IndexPath!
	
	@IBOutlet weak var lblTitle: NSTextField!
	@IBOutlet weak var imgIcon: NSImageView!
	@IBOutlet weak var sideNavImgIcon: NSImageView!
	
	override var isSelected: Bool {
		didSet {
			// set text color
			lblTitle.textColor = isSelected ? NSColor.white: NSColor(rgb: 0xa9b9be)
			
			if let item = self.item {
				self.imgIcon.image = NSImage(named: item.iconName(active: isSelected))
			}
			
			// set title text & underline style
			let text = NSMutableAttributedString(string: lblTitle.stringValue)
			if isSelected {
				let attrs = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
				text.addAttributes(attrs, range: NSRange(location: 0, length: text.length))
				if let f = NSFont(name: "RobotoCondensed-Bold", size: 14) {
					text.addAttributes([NSAttributedString.Key.font: f], range: NSRange(location: 0, length: text.length))
				}
			}
			self.lblTitle.attributedStringValue = text
			self.sideNavImgIcon.isHidden = !isSelected
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		self.lblTitle.font = NSFont(name: "RobotoCondensed-Bold", size: 14)
	}
	
	func update(_ item: MenuItem, for indexPath: IndexPath?) {
		self.item = item
		self.indexPath = indexPath
		self.lblTitle.stringValue = item.title
		self.imgIcon.image = NSImage(named: item.iconName(active: false))
	}
}
