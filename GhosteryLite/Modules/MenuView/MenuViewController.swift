//
// MenuViewController
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

class MenuViewController: NSViewController {
	
	var delegate: MenuViewControllerDelegate? = nil
	let items: [MenuItem] = [.home, .settings, .trustedSites, .help]
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
			self.selectItem(atIndex: 0)
		})
	}
	
	func selectItem(menuItem item: MenuItem) {
		if let itemIndex = items.firstIndex(of: item) {
			selectItem(atIndex: itemIndex)
		}
	}
	
	private func selectItem(atIndex itemIndex: Int) {
		self.collectionView.deselectItems(at: self.collectionView.selectionIndexPaths)
		
		let indexPath = IndexPath(item: itemIndex, section: 0)
		let indexPathSet = Set<IndexPath>(arrayLiteral: indexPath)
		self.collectionView.selectItems(at: indexPathSet, scrollPosition: .top)
		self.delegate?.menuViewController(self, didSelectSectionItem: items[itemIndex])
	}
	
}
