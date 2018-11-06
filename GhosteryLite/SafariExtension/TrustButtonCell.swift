//
//  TrustButtonCell.swift
//  SafariExtension
//
//  Created by Sahakyan on 11/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
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
