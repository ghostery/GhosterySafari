//
//  ReloadPopupView.swift
//  SafariExtension
//
//  Created by Sahakyan on 9/4/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class ReloadPopupView: NSView {
	
	@IBOutlet var backgroundBox: NSBox!
	@IBOutlet var titleLabel: NSTextField!
	@IBOutlet var closeButton: NSButton!
	@IBOutlet var reloadButton: NSButton!

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.initComponents()
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		self.initComponents()
	}

	private func initComponents() {
		backgroundBox.fillColor = NSColor.yellow
	}
}
