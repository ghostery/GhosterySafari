//
// TrustedSitesViewController
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

class TrustedSitesViewController: NSViewController {
	
	@IBOutlet weak var trustedSitesTitle: NSTextField!
	@IBOutlet weak var trustedSiteTextField: NSTextField!
	@IBOutlet weak var trustSiteBtn: NSButton!
	@IBOutlet weak var trustedStiesCollectionView: NSCollectionView!
	
	@IBOutlet weak var errorMessageLabel: NSTextField!
	
	private var trustedSites = [TrustedSiteObject]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateData),
															name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateData),
															name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		updateData()
	}
	
	deinit {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	@IBAction func trustSiteButtonPressed(sender: NSButton) {
		guard trustedSiteTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 &&
			self.isValid(url: trustedSiteTextField.stringValue) else {
				self.errorMessageLabel.isHidden = false
				return
		}
		let str = trustedSiteTextField.stringValue.lowercased()
		let regEx = try? NSRegularExpression(pattern: "(^https?://)?(www\\.)?", options: .caseInsensitive)
		if let newStr = regEx?.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.count), withTemplate: "") {
			self.errorMessageLabel.isHidden = true
			ContentBlockerManager.shared.trustDomain(domain: newStr)
			updateData()
		}
		trustedSiteTextField.stringValue = ""
		updateTrustBtnState(false)
	}
	
	@objc
	private func updateData() {
		self.trustedSites = TrustedSitesDataSource.shared.allTrustedSites()
		trustedStiesCollectionView.reloadData()
	}
	
	private func setupComponents() {
		trustedStiesCollectionView.backgroundColors = [NSColor.clear]
		trustedSiteTextField.backgroundColor = NSColor.clear
		trustedSitesTitle.attributedStringValue = trustedSitesTitle.stringValue.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: NSColor.panelTextColor(), isUnderline: false, lineSpacing: 3)
		trustSiteBtn.attributedTitle = trustSiteBtn.title.attributedString(withTextAlignment: .center, fontName: "Roboto-Medium", fontSize: 12.0, fontColor: NSColor(named: "trustBtnText") ?? NSColor.black)
		errorMessageLabel.font = NSFont(name: "Roboto-Regular", size: 10)
		trustSiteBtn.attributedAlternateTitle = trustSiteBtn.title.attributedString(withTextAlignment: .center, fontName: "Roboto-Medium", fontSize: 12.0, fontColor: NSColor(rgb: 0xffffff))
	}
	
	// Move the logic to TrustSiteDS
	private func isValid(url: String) -> Bool {
		let host = removeUrlComponentsAfterHost(url: url)
		let urlRegEx = "((?:http|https)://)?(((?:www)?|(?:[a-zA-z0-9]{1,})?)\\.)?[\\w\\d\\-_]+\\.(\\w{2,}?|(xn--\\w{2,})?)(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
		let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
		let result = urlTest.evaluate(with: host)
		return result
	}
	
	private func removeUrlComponentsAfterHost(url: String) -> String {
		var host = ""
		var firstSlashRange: Range<String.Index>?
		if let protocolRange = url.range(of: "://") {
			let searchRange = Range<String.Index>(uncheckedBounds: (lower: protocolRange.upperBound, upper: url.endIndex))
			firstSlashRange = url.range(of: "/", options: .literal, range: searchRange, locale: Locale.current)
		} else {
			firstSlashRange = url.range(of: "/", options: .literal, range: nil, locale: Locale.current)
		}
		host = String(url[..<(firstSlashRange?.lowerBound ?? url.endIndex)])
		return host
	}
	
	fileprivate func updateTrustBtnState(_ isEnabled: Bool) {
		trustSiteBtn.isEnabled = isEnabled
		trustSiteBtn.state = NSControl.StateValue(rawValue: isEnabled ? 1 : 0)
	}
	
}

// MARK:- Collection view data source
// MARK:-
extension TrustedSitesViewController : NSCollectionViewDataSource {
	
	// Section Header Count
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	// Section Item Count
	func collectionView(_ collectionView: NSCollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return self.trustedSites.count
	}
	
	// Section Item
	func collectionView(_ collectionView: NSCollectionView,
						itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let trustedSiteItemCollectionView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TrustedSiteItemCollectionViewItem"), for: indexPath)
		guard let trustedSiteView = trustedSiteItemCollectionView as? TrustedSiteItemCollectionViewItem else {
			return trustedSiteItemCollectionView
		}
		trustedSiteView.delegate = self
		//TODO: update the cell with the actual data
		let obj = self.trustedSites[indexPath.item]
		if let n = obj.name {
			trustedSiteView.update(n, for: indexPath)
		}
		return trustedSiteView
	}
}

extension TrustedSitesViewController: TrustedSiteItemDelegate {
	
	func trustedSiteDidRemove(indexPath: IndexPath, url: String) {
		ContentBlockerManager.shared.untrustDomain(domain: self.trustedSites[indexPath.item].name ?? "")
		updateData()
	}
}

// MARK:- Collection view delegate
// MARK:-
extension TrustedSitesViewController : NSCollectionViewDelegate {
	func collectionView(_ collectionView: NSCollectionView,
						didSelectItemsAt indexPaths: Set<IndexPath>) {
		
	}
}

extension TrustedSitesViewController: NSTextFieldDelegate {
	
	func controlTextDidChange(_ obj: Notification) {
		self.updateTrustBtnState(trustedSiteTextField.stringValue != "")
	}
}