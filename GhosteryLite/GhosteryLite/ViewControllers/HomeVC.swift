//
//  HomeVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import SafariServices

class HomeVC: NSViewController {

    @IBOutlet weak var titleText: NSTextField!
    @IBOutlet weak var subtitleText: NSTextField!
    @IBOutlet weak var editSettingsText: NSTextField!
    @IBOutlet weak var editSettingsBtn: NSButton!
    @IBOutlet weak var trustedSitesText: NSTextField!
    @IBOutlet weak var trustedSitesBtn: NSButton!
    @IBOutlet weak var SafariExtensionPromptView: NSBox!
    @IBOutlet weak var enableGhosteryLitePromptText: NSTextField!
    @IBOutlet weak var enableGhosteryLiteBtn: NSButton!
    
    
    var delegate: SectionDetailVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        if !Preferences.isAppFirstLaunch() {
			Preferences.areExtensionsEnabled { (contentBlockerEnabled, popoverEnabled, error) in
				self.SafariExtensionPromptView.isHidden = contentBlockerEnabled && popoverEnabled
			}
        }
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.editSettingsClicked(_:)),
															name: Constants.NavigateToSettingsNotificationName, object: Constants.SafariPopupExtensionID)
    }

	override func viewDidAppear() {
		super.viewDidAppear()
		TelemetryManager.shared.sendSignal(.engage)
	}

    @IBAction func enableGhosteryLite(_ sender: NSButton) {
        self.SafariExtensionPromptView.isHidden = true
		HomeVC.showSafariPreferencesForExtension()
    }
    
    @IBAction func editSettingsClicked(_ sender: Any) {
        self.delegate?.showSettingsPanel()
    }
    
    @IBAction func trustedSitesClicked(_ sender: Any) {
        self.delegate?.showTrustedSitesPanel()
    }
	
	class func showSafariPreferencesForExtension() {
		SFSafariApplication.showPreferencesForExtension(withIdentifier: Constants.SafariContentBlockerID, completionHandler: { (error) in
			if let e = error {
				print("Error --- \(e)")
			} else {
				print("Success!!!")
			}
		})
	}

    private func initComponents() {
        titleText.stringValue = Strings.HomePanelTitle
		titleText.font = NSFont(name: "Roboto-Regular", size: 24)
        subtitleText.attributedStringValue = Strings.HomePanelSubtitle.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: 0x4a4a4a, isUnderline: false, lineSpacing: 6)
        enableGhosteryLitePromptText.stringValue = Strings.HomePanelEnableGhosteryLitePromptText

        editSettingsText.attributedStringValue = generateAttributedString(prefix: Strings.HomePanelSettingsDescriptionPrefix,
                                                                          regularText: Strings.HomePanelSettingsDescription)
        
        trustedSitesText.attributedStringValue = generateAttributedString(prefix: Strings.HomePanelTrustedSitesDescriptionPrefix,
                                                                          regularText: Strings.HomePanelTrustedSitesDescription)
        
        editSettingsBtn.attributedTitle = Strings.HomePanelEditSettingsButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                    fontName: "RobotoCondensed-Bold",
                                                                                                    fontSize: 14.0,
                                                                                                    fontColor: 0x930194)
        
        trustedSitesBtn.attributedTitle = Strings.HomePanelTrustedSitesButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                    fontName: "RobotoCondensed-Bold",
                                                                                                    fontSize: 14.0,
                                                                                                    fontColor: 0x930194)
        
        enableGhosteryLiteBtn.attributedTitle = Strings.HomePanelEnableGhosteryLiteButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                               fontName: "Roboto-Regular",
                                                                                                               fontSize: 14.0,
                                                                                                               fontColor: 0x4a4a4a)
    }
    
    private func generateAttributedString(prefix: String, regularText: String) -> NSAttributedString {
        let prefixString = prefix.attributedString(withTextAlignment: .left, fontName: "Roboto-Medium", fontSize: 16.0, fontColor: 0x4a4a4a, lineSpacing: 12.0)
        let regularTextString = " \(regularText)".attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16.0, fontColor: 0x4a4a4a, lineSpacing: 12.0)
        
        let attrString:NSMutableAttributedString = NSMutableAttributedString(attributedString: prefixString)
        attrString.append(regularTextString)
        
        return attrString
    }
    
    
}
