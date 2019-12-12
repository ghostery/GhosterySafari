//
// TrustedSiteTextFieldCell
// GhosteryLite
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

class TrustedSiteTextFieldCell: NSTextFieldCell {
	/// Vertical center content in NSTextFieldCell
	/// - Parameter rect: The bounding rectangle of the receiver
	override func titleRect(forBounds rect: NSRect) -> NSRect {
		var titleRect = super.titleRect(forBounds: rect)
		let minimumHeight = self.cellSize(forBounds: rect).height
		titleRect.origin.y += (titleRect.height - minimumHeight) / 2
		titleRect.size.height = minimumHeight

		return titleRect
	}
	
	/// Draws the interior portion of the receiver, which includes the image or text portion but does not include the border.
	/// - Parameters:
	///   - cellFrame: The bounding rectangle of the receiver, or a portion of the bounding rectangle.
	///   - controlView: The control that manages the cell.
	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
	}
	
	/// Selects the specified text range in the cell's field editor.
	/// - Parameters:
	///   - rect: The bounding rectangle of the cell.
	///   - controlView: The control that manages the cell.
	///   - textObj: The field editor to use for editing the cell.
	///   - delegate: The object to use as a delegate for the field editor
	///   - selStart: The start of the text selection.
	///   - selLength: The length of the text range
	override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
		super.select(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
	}
}
