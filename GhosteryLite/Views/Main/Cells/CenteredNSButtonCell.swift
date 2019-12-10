//
// CenteredNSButtonCell
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

class CenteredNSButtonCell: NSButtonCell {
	/// Vertical center content in NSButtonCell
	/// - Parameter rect: The bounding rectangle of the receiver
	override func titleRect(forBounds rect: NSRect) -> NSRect {
		var titleRect = super.titleRect(forBounds: rect)
		titleRect.origin.y = rect.origin.y + rect.size.height - (titleRect.size.height + (titleRect.origin.y - rect.origin.y)) - 1;
		return titleRect
	}
}
