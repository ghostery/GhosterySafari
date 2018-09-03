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

	@IBOutlet var pauseButton: NSButton!

	@IBOutlet var trustSiteButton: NSButton!

	private var isPaused = false
	
	var currentDomain: String? {
		didSet {
			urlLabel?.stringValue = currentDomain ?? ""
			updateTrustButtonState()
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
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		self.view.layer?.backgroundColor = NSColor.white.cgColor
		urlLabel?.stringValue = self.currentDomain ?? ""
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		if d?.bool(forKey: "isDefault") ?? true {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func pauseButtonPressed(sender: NSButton) {
		self.isPaused = sender.state.rawValue == 1
		if sender.state.rawValue == 1 {
			AntiTrackingManager.shared.pause()
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		} else {
			AntiTrackingManager.shared.resume()
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: "Gh.GhosteryLite.SafariExtension")
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
			DistributedNotificationCenter.default().post(name: Constants.SwitchToDefaultNotificationName, object: "Gh.GhosteryLite.SafariExtension")

//			AntiTrackingManager.shared.switchToDefault()
		} else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
			AntiTrackingManager.shared.switchToCustom()
		}
	}

	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToCustomNotificationName, object: "Gh.GhosteryLite.SafariExtension")
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

	private func updateTrustButtonState() {
		if let d = self.currentDomain {
			if AntiTrackingManager.shared.isTrustedDomain(domain: d) {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 1)
			} else {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 0)
			}
		}
	}
}
