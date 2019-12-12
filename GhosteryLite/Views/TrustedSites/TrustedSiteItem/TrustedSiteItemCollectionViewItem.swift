//
// TrustedSiteItemCollectionViewItem
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

class TrustedSiteItemCollectionViewItem: NSCollectionViewItem {
	
	weak var delegate: TrustedSiteItemDelegate?
	private var indexPath: IndexPath!
	
	@IBOutlet weak var siteLbl: NSTextField!
	
	/// Action taken when the remove button is selected
	/// - Parameter sender: Remove trusted site icon
	@IBAction func removeTrustedSite(_ sender: Any) {
		self.delegate?.trustedSiteDidRemove(indexPath: self.indexPath, url: self.siteLbl.stringValue)
	}
	
	/// Called after the view controller’s view has been loaded into memory.
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
	}
	
	/// Update attributes for the trusted site view item
	/// - Parameters:
	///   - url: The trusted site URL
	///   - indexPath: The IndexPath
	func update(_ url: String, for indexPath: IndexPath?) {
		self.siteLbl.attributedStringValue = url.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 14, fontColor: NSColor.panelTextColor())
		self.indexPath = indexPath
	}
}
