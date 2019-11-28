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
	// Section Header Count
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	// Section Item Count
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.trustedSites.count
	}
	
	// Section Item
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
	func trustedSiteDidRemove(indexPath: IndexPath, url: String) {
		GhosteryApplication.shared.untrustDomain(domain: self.trustedSites[indexPath.item])
		self.updateData()
	}
}

extension TrustedSitesViewController: NSCollectionViewDelegate {
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		
	}
}

extension TrustedSitesViewController: NSTextFieldDelegate {
	func controlTextDidChange(_ obj: Notification) {
		self.updateTrustBtnState(trustedSiteTextField.stringValue != "")
	}
}
