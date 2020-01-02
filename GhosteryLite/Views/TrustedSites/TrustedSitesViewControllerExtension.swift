//
// TrustedSitesViewControllerExtension
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

extension TrustedSitesViewController: NSCollectionViewDataSource {
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
		return self.trustedSites.count
	}
	
	/// Asks your data source object to provide the item at the specified location in the collection view.
	/// - Parameters:
	///   - collectionView: The collection view requesting the information.
	///   - indexPath: The index path that specifies the location of the item.
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let trustedSiteItemCollectionView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TrustedSiteItemCollectionViewItem"), for: indexPath)
		guard let trustedSiteView = trustedSiteItemCollectionView as? TrustedSiteItemCollectionViewItem else {
			return trustedSiteItemCollectionView
		}
		trustedSiteView.delegate = self
		//TODO: update the cell with the actual data
		let obj = self.trustedSites[indexPath.item]
		trustedSiteView.update(obj, for: indexPath)
		return trustedSiteView
	}
}

extension TrustedSitesViewController: TrustedSiteItemDelegate {
	/// Remove the domain from the trusted sites list
	/// - Parameters:
	///   - indexPath: The indexPath in the list
	///   - url: The trusted site URL
	func trustedSiteDidRemove(indexPath: IndexPath, url: String) {
		GhosteryApplication.shared.untrustDomain(domain: self.trustedSites[indexPath.item])
		self.updateData()
	}
}

extension TrustedSitesViewController: NSTextFieldDelegate {
	/// Listen for changes to the Trusted Sites text field
	/// - Parameter obj: The object that was changed
	func controlTextDidChange(_ obj: Notification) {
		self.updateTrustButtonState(self.trustedSiteTextField.stringValue != "")
	}
}
