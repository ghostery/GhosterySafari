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

import Cocoa

extension MenuViewController: NSCollectionViewDataSource {
	/// Asks your data source object to provide the total number of sections.
	/// - Parameter collectionView: The collection view requesting the information.
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	/// Asks your data source object to provide the number of items in the specified section.
	/// - Parameters:
	///   - collectionView: The collection view requesting the information.
	///   - section: The index number of the section. Section indexes are zero based.
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count
	}
	
	/// Asks your data source object to provide the item at the specified location in the collection view.
	/// - Parameters:
	///   - collectionView: The collection view requesting the information.
	///   - indexPath: The index path that specifies the location of the item.
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let itemView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MenuItemCollectionViewItem"), for: indexPath)
		guard let sectionItemView = itemView as? MenuItemCollectionViewItem else { return itemView }
		
		let item = self.items[indexPath.item]
		sectionItemView.update(item, for: indexPath)
		return sectionItemView
	}
}

extension MenuViewController: NSCollectionViewDelegate {
	/// Notifies the delegate object that one or more items were selected.
	/// - Parameters:
	///   - collectionView: The collection view notifying you of the selection change.
	///   - indexPaths: The set of NSIndexPath objects corresponding to the items that are now selected.
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		let item = self.items[indexPaths.first!.item]
		self.delegate?.menuViewController(self, didSelectSectionItem: item)
	}
}
