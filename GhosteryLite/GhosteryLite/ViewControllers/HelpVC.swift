//
//  HelpVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/29/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class HelpVC: NSViewController {

    @IBOutlet weak var helpText: NSTextField!
    @IBOutlet weak var supportBtn: NSButton!
    @IBOutlet weak var productsBtn: NSButton!
    @IBOutlet weak var blogBtn: NSButton!
    @IBOutlet weak var faqBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         initComponents()
    }
    
    @IBAction func HelpLinkClicked(_ sender: NSButton) {
        if sender == supportBtn {
            openURL("https://ghostery.zendesk.com/hc/en-us")
        } else if sender == productsBtn {
            openURL("https://www.ghostery.com/products/")
        } else if sender == blogBtn {
            openURL("https://www.ghostery.com/blog/")
        } else if sender == faqBtn {
            openURL("https://www.ghostery.com/faqs/")
        }
        
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func initComponents() {
//        helpText.stringValue = Strings.HelpPanelText
		self.helpText.attributedStringValue = Strings.HelpPanelText.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: NSColor.panelTextColor(), isUnderline: false, lineSpacing: 3)

        supportBtn.attributedTitle = Strings.HelpPanelSupportButtonTitle.attributedString(withTextAlignment: .left,
                                                                                          fontName: "Roboto-Regular",
                                                                                          fontSize: 14.0,
                                                                                          fontColor: NSColor(named: NSColor.Name("linkColor")) ?? NSColor.linkColor,
                                                                                          isUnderline: true)
        
        
        productsBtn.attributedTitle = Strings.HelpPanelProductsButtonTitle.attributedString(withTextAlignment: .left,
                                                                                            fontName: "Roboto-Regular",
                                                                                            fontSize: 14.0,
                                                                                            fontColor: NSColor(named: NSColor.Name("linkColor")) ?? NSColor.linkColor,
                                                                                            isUnderline: true)
        
        
        blogBtn.attributedTitle = Strings.HelpPanelBlogButtonTitle.attributedString(withTextAlignment: .left,
                                                                                    fontName: "Roboto-Regular",
                                                                                    fontSize: 14.0,
                                                                                    fontColor: NSColor(named: NSColor.Name("linkColor")) ?? NSColor.linkColor,
                                                                                    isUnderline: true)
        
        
        faqBtn.attributedTitle = Strings.HelpPanelFaqsButtonTitle.attributedString(withTextAlignment: .left,
                                                                                   fontName: "Roboto-Regular",
                                                                                   fontSize: 14.0,
                                                                                   fontColor: NSColor(named: NSColor.Name("linkColor")) ?? NSColor.linkColor,
                                                                                   isUnderline: true)
        
    }
}
