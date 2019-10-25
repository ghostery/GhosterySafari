//
// StringExtension.swift
// Ghostery Lite
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

/// Custom string utilities
extension String {
	/// Adds attributes to the current String and returns NSAttributedString
	/// - Parameter textAlignment: Alignment
	/// - Parameter fontName: Font family
	/// - Parameter size: Font size
	/// - Parameter color: Font color
	/// - Parameter isUnderline: Underline
	/// - Parameter lineSpacing: Line spacing
	func attributedString(withTextAlignment textAlignment : NSTextAlignment, fontName: String, fontSize size: CGFloat, fontColor color: NSColor, isUnderline: Bool = false, lineSpacing: CGFloat = 10.0) -> NSAttributedString {
		guard let font:NSFont = NSFont(name: fontName, size: size) else {
			return NSAttributedString.init(string: self)
		}
		let textColor:NSColor = color
		let textParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
		// this sets the space BETWEEN lines to 10points
		textParagraph.lineSpacing = lineSpacing
		// this sets the MAXIMUM height of the lines to 12points
		textParagraph.maximumLineHeight = 30.0
		textParagraph.alignment = textAlignment
		let attribs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
													NSAttributedString.Key.foregroundColor : textColor,
													NSAttributedString.Key.paragraphStyle : textParagraph,
													NSAttributedString.Key.underlineStyle : isUnderline ? NSUnderlineStyle.single.rawValue : 0]
		let attrString:NSAttributedString = NSAttributedString.init(string: self, attributes: attribs)
		return attrString
	}
}
