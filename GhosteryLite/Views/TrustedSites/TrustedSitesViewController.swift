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
	
	var trustedSites = [String]()
	
	@IBOutlet weak var trustedSitesTitle: NSTextField!
	@IBOutlet weak var trustedSiteTextField: NSTextField!
	@IBOutlet weak var trustSiteBtn: NSButton!
	@IBOutlet weak var trustedStiesCollectionView: NSCollectionView!
	@IBOutlet weak var errorMessageLabel: NSTextField!
	
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
			GhosteryApplication.shared.trustDomain(domain: newStr)
			self.updateData()
		}
		trustedSiteTextField.stringValue = ""
		updateTrustBtnState(false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateData), name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateData), name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		self.updateData()
	}
	
	deinit {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
	}
	
	func updateTrustBtnState(_ isEnabled: Bool) {
		trustSiteBtn.isEnabled = isEnabled
		trustSiteBtn.state = NSControl.StateValue(rawValue: isEnabled ? 1 : 0)
	}
	
	@objc func updateData() {
		if let sites = TrustedSite.shared.getTrustedSites() {
			self.trustedSites = sites
		}
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
		let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
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
}
