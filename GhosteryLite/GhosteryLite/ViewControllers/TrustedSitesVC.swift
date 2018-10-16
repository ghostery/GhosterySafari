//
//  TrustedSitesVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class TrustedSitesVC: NSViewController {

    @IBOutlet weak var trustedSitesText: NSTextField!
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
			AntiTrackingManager.shared.trustDomain(domain: newStr)
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
		trustedSitesText.stringValue = Strings.TrustedSitesPanelText
		trustedSitesText.attributedStringValue = Strings.TrustedSitesPanelText.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: NSColor.panelTextColor(), isUnderline: false, lineSpacing: 3)
		trustedSitesText.font = NSFont(name: "Roboto-Regular", size: 16)
		trustSiteBtn.attributedTitle = Strings.TrustedSitesPanelTrustSiteButtonTitle.attributedString(withTextAlignment: .center,
																									  fontName: "Roboto-Medium",
																									  fontSize: 12.0,
																									  fontColor: NSColor(named: NSColor.Name("trustBtnText")) ?? NSColor.black)
		errorMessageLabel.font = NSFont(name: "Roboto-Regular", size: 10)
		errorMessageLabel.stringValue = "Please enter a valid URL."
		trustSiteBtn.attributedAlternateTitle = Strings.TrustedSitesPanelTrustSiteButtonTitle.attributedString(withTextAlignment: .center, fontName: "Roboto-Medium", fontSize: 12.0, fontColor: NSColor(rgb: 0xffffff))
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
extension TrustedSitesVC : NSCollectionViewDataSource {
    
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
        let trustedSiteCollectionView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TrustedSiteCollectionViewItem"), for: indexPath)
        guard let trustedSiteView = trustedSiteCollectionView as? TrustedSiteCollectionViewItem else { return trustedSiteCollectionView }
        trustedSiteView.delegate = self
        //TODOL update the cell with the actual data
		let obj = self.trustedSites[indexPath.item]
		if let n = obj.name {
			trustedSiteView.update(n, for: indexPath)
		}
        return trustedSiteView
    }
}

extension TrustedSitesVC: TrustedSiteDelegate {

	func trustedSiteDidRemove(indexPath: IndexPath, url: String) {
		AntiTrackingManager.shared.untrustDomain(domain: self.trustedSites[indexPath.item].name ?? "")
		updateData()
	}
}

// MARK:- Collectin view delegate
// MARK:-
extension TrustedSitesVC : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        
    }
}

extension TrustedSitesVC: NSTextFieldDelegate {

	override func controlTextDidChange(_ obj: Notification) {
		self.updateTrustBtnState(trustedSiteTextField.stringValue != "")
	}
}
