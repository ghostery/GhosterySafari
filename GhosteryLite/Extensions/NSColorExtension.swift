//
// NSColorExtension
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

extension NSColor {
	/// Initializes and returns a color object for the given RGB hex integer.
	/// - Parameters:
	///   - rgb: RGB value
	///   - alpha: Alpha value
	public convenience init(rgb: Int, alpha: CGFloat = 1.0) {
		self.init(
			red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
			blue: CGFloat((rgb & 0x0000FF) >> 0)  / 255.0,
			alpha: alpha)
	}
	
	public static func panelTextColor() -> NSColor {
		return NSColor(named: "panelText") ?? NSColor.white
	}
}
