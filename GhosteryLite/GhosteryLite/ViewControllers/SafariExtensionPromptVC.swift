//
//  SafariExtensionPromptVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/28/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
protocol SafariExtensionPromptVCDelegate {
    func hideSafariExtensionPopOver()
}

class SafariExtensionPromptVC: NSViewController {

    @IBOutlet weak var enableGhosteryLiteText: NSTextField!
    @IBOutlet weak var enableGhosteryLiteBtn: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    
    
    var delegate: SafariExtensionPromptVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    @IBAction func enableGhosteryLite(_ sender: NSButton) {
        self.delegate?.hideSafariExtensionPopOver()
        Preferences.enableGhosteryLite()
    }
    
    @IBAction func skip(_ sender: NSButton) {
        self.delegate?.hideSafariExtensionPopOver()
    }
    
    private func initComponents() {
        enableGhosteryLiteText.stringValue = Strings.SafariExtensionPromptText
        
        enableGhosteryLiteBtn.attributedTitle = Strings.SafariExtensionPromptEnableGhosteryLiteButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                                           fontName: "Roboto-Medium",
                                                                                                                           fontSize: 14.0,
                                                                                                                           fontColor: 0xffffff,
                                                                                                                           isUnderline: true)
        
        skipButton.attributedTitle = Strings.SafariExtensionPromptSkipButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                  fontName: "Roboto-Regular",
                                                                                                  fontSize: 14.0,
                                                                                                  fontColor: 0x4a4a4a,
                                                                                                  isUnderline: true)
        
    }
}
