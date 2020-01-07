//
// PaddedNSButton
// GhosteryLite
//
// Ghostery Lite for Safari
// https://www.ghostery.com/
//
// Copyright 2020 Ghostery, Inc. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0
// 

import Cocoa

/// Overrides intrinsicContentSize() to allow button padding
class PaddedNSButton: NSButton {
	
	@IBInspectable var horizontalPadding: CGFloat = 0
	@IBInspectable var verticalPadding: CGFloat = 0

	override var intrinsicContentSize: NSSize {
		var size = super.intrinsicContentSize
		size.width += self.horizontalPadding
		size.height += self.verticalPadding
		return size;
	}
}
