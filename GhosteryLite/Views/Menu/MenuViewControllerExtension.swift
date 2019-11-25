//
// MenuViewControllerExtension
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

extension MenuViewController: NSCollectionViewDataSource {
	
	// Section Header Count
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	// Section Item Count
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count
	}
	
	// Section Item
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let itemView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MenuItemCollectionViewItem"), for: indexPath)
		guard let sectionItemView = itemView as? MenuItemCollectionViewItem else { return itemView }
		
		let item = self.items[indexPath.item]
		sectionItemView.update(item, for: indexPath)
		return sectionItemView
	}
}

extension MenuViewController: NSCollectionViewDelegate {
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		let item = self.items[indexPaths.first!.item]
		self.delegate?.menuViewController(self, didSelectSectionItem: item)
	}
}
