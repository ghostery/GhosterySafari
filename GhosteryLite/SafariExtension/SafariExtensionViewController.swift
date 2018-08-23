//
//  SafariExtensionViewController.swift
//  SafariExtension
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared = SafariExtensionViewController()

	@IBOutlet var urlLabel: NSTextField!

	var currentUrl: String? {
		didSet {
			urlLabel?.stringValue = currentUrl ?? ""
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 273)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
//		self.view.layer?.backgroundColor = NSColor.white.cgColor
		urlLabel?.stringValue = currentUrl ?? ""
	}

}
