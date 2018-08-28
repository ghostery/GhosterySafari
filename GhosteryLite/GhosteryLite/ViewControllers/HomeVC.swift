//
//  HomeVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class HomeVC: NSViewController {

    @IBOutlet weak var editSettingsText: NSTextField!
    @IBOutlet weak var trustedSitesText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initComponent()
    }
    
    private func initComponent() {
        editSettingsText.attributedStringValue = generateAttributedString(prefix: "Want more control? ", regularText: "Select the categories of tracker your wish to allow.")
        trustedSitesText.attributedStringValue = generateAttributedString(prefix: "Do you know who to trust? ", regularText: "Add or remove sites from your ‘Trusted’ list.")
    }
    
    private func generateAttributedString(prefix: String, regularText: String) -> NSAttributedString {
        let prefixString = generateAttributedString(prefix, fontName: "Roboto-Medium")
        let regularTextString = generateAttributedString(regularText, fontName: "Roboto-Regular")
        
        let attrString:NSMutableAttributedString = NSMutableAttributedString(attributedString: prefixString)
        attrString.append(regularTextString)
        
        return attrString
    }
    
    private func generateAttributedString(_ text: String, fontName: String) -> NSAttributedString {
        guard let font:NSFont = NSFont(name: fontName, size: 16.0) else {
            return NSMutableAttributedString.init(string: text)
        }
        let textColor:NSColor = NSColor(rgb: 0x4a4a4a)
        let textParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
        textParagraph.lineSpacing = 10.0  /*this sets the space BETWEEN lines to 10points*/
        textParagraph.maximumLineHeight = 30.0/*this sets the MAXIMUM height of the lines to 12points*/
        let attribs = [NSAttributedStringKey.font : font,
                       NSAttributedStringKey.foregroundColor : textColor,
                       NSAttributedStringKey.paragraphStyle : textParagraph]
        let attrString:NSMutableAttributedString = NSMutableAttributedString.init(string: text, attributes: attribs)
        return attrString
    }
}
