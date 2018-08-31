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
	@IBOutlet var pageLatencyLabel: NSTextField!
	@IBOutlet var pageLatencyImage: NSImageView!

	@IBOutlet var defaultConfigRadio: NSButton!
	@IBOutlet var customConfigRadio: NSButton!

	var currentDomain: String? {
		didSet {
			urlLabel?.stringValue = currentDomain ?? ""
		}
	}

	var currentUrl: String? {
		didSet {
			pageLatencyLabel?.stringValue = PageLatencyDataSource.shared.latencyFor(currentUrl ?? "")
			pageLatencyImage?.image = NSImage(named: NSImage.Name(PageLatencyDataSource.shared.latencyImageName(currentUrl ?? "")))
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 282)
		self.view.layer?.backgroundColor = NSColor.white.cgColor
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		urlLabel?.stringValue = self.currentDomain ?? ""
		if AntiTrackingManager.shared.isDefaultConfigEnabled() {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func pauseButtonPressed(sender: NSButton) {
		if sender.isEnabled {
			AntiTrackingManager.shared.pause()
		} else {
			AntiTrackingManager.shared.resume()
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		AntiTrackingManager.shared.trustDomain(domain: self.currentDomain ?? "")
	}

	@IBAction func threedotsButtonPressed(sender: NSButton) {
		openSettings()
	}

	@IBAction func defaultConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			AntiTrackingManager.shared.switchToDefault()
		} else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
			AntiTrackingManager.shared.switchToCustom()
		}
	}

	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			AntiTrackingManager.shared.switchToCustom()
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
			AntiTrackingManager.shared.switchToDefault()
		}
	}

	func updatePageLatency(_ url: String, _ latency: String) {
		self.currentUrl = url
	}

	private func openSettings() {
		
	}
}
