//
// TrustButtonCell
// SafariExtension
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

import Foundation
import SafariServices

class TrustButtonCell: NSButtonCell {
	
	override func titleRect(forBounds rect: NSRect) -> NSRect {
		var theRect = super.titleRect(forBounds: rect)
		theRect.origin.y = rect.origin.y + rect.size.height - (theRect.size.height+(theRect.origin.y-rect.origin.y)) - 1
		theRect.origin.x = theRect.origin.x + 8
		return theRect
	}
}
