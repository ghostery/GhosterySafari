//
//  StringExtension.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/29/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

extension String {
	func attributedString(withTextAlignment textAlignment : NSTextAlignment, fontName: String, fontSize size: CGFloat, fontColor color: NSColor, isUnderline: Bool = false, lineSpacing: CGFloat = 10.0) -> NSAttributedString {
        guard let font:NSFont = NSFont(name: fontName, size: size) else {
            return NSAttributedString.init(string: self)
        }
        let textColor:NSColor = color
        let textParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
        textParagraph.lineSpacing = lineSpacing /*this sets the space BETWEEN lines to 10points*/
        textParagraph.maximumLineHeight = 30.0 /*this sets the MAXIMUM height of the lines to 12points*/
        textParagraph.alignment = textAlignment
        let attribs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                      NSAttributedString.Key.foregroundColor : textColor,
                                                      NSAttributedString.Key.paragraphStyle : textParagraph,
                                                      NSAttributedString.Key.underlineStyle : isUnderline ? NSUnderlineStyle.single.rawValue : 0]
        let attrString:NSAttributedString = NSAttributedString.init(string: self, attributes: attribs)
        return attrString
    }
}
