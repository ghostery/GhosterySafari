//
//  SafariExtensionPromptVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/28/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class SafariExtensionPromptVC: NSViewController {

    @IBOutlet weak var enableGhosteryLiteText: NSTextField!
    @IBOutlet weak var enableGhosteryLiteBtn: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    @IBAction func enableGhosteryLite(_ sender: NSButton) {
         self.dismiss(nil)
    }
    @IBAction func skip(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    
    private func initComponents() {
        enableGhosteryLiteText.stringValue = Strings.SafariExtensionPromptText
        
        enableGhosteryLiteBtn.attributedTitle = Strings.SafariExtensionPromptEnableGhosteryLiteButtonText.attributedString(withTextAlignment: .center,
                                                                                                                           fontName: "Roboto-Medium",
                                                                                                                           fontSize: 14.0,
                                                                                                                           fontColor: 0xffffff)
        
        skipButton.attributedTitle = Strings.SafariExtensionPromptSkipButtonText.attributedString(withTextAlignment: .center,
                                                                                                  fontName: "Roboto-Regular",
                                                                                                  fontSize: 14.0,
                                                                                                  fontColor: 0x4a4a4a)
        
    }
}
