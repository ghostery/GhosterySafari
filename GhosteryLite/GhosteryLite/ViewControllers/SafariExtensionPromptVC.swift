//
//  SafariExtensionPromptVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/28/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class SafariExtensionPromptVC: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enableGhosteryLite(_ sender: NSButton) {
         self.dismiss(nil)
    }
    @IBAction func skip(_ sender: NSButton) {
        self.dismiss(nil)
    }
}
