//
//  StringExtension.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/29/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

extension String {
    func attributedString(withTextAlignment textAlignment : NSTextAlignment, fontName: String, fontSize size: CGFloat, fontColor color: Int) -> NSAttributedString {
        guard let font:NSFont = NSFont(name: fontName, size: size) else {
            return NSMutableAttributedString.init(string: self)
        }
        let textColor:NSColor = NSColor(rgb: color)
        let textParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
        textParagraph.lineSpacing = 10.0  /*this sets the space BETWEEN lines to 10points*/
        textParagraph.maximumLineHeight = 30.0/*this sets the MAXIMUM height of the lines to 12points*/
        textParagraph.alignment = textAlignment
        let attribs = [NSAttributedStringKey.font : font,
                       NSAttributedStringKey.foregroundColor : textColor,
                       NSAttributedStringKey.paragraphStyle : textParagraph]
        let attrString:NSAttributedString = NSAttributedString.init(string: self, attributes: attribs)
        return attrString
    }
}
