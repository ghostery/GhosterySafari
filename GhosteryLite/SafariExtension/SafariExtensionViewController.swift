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

	private static let CustomSettingsSelectedKey = "CustomSettingsSelectedOnce"

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
			self.pauseButton.toolTip = "Resume Ghostery Lite"
//			AntiTrackingManager.shared.pause()
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		} else {
//			AntiTrackingManager.shared.resume()
			self.pauseButton.toolTip = "Pause Ghostery Lite"
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		if sender.state.rawValue == 0 {
			DistributedNotificationCenter.default().post(name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID, userInfo: ["domain": self.currentDomain ?? ""])
//			post(name: Constants.ResumeNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		} else {
			DistributedNotificationCenter.default().post(name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID, userInfo: ["domain": self.currentDomain ?? ""])
		}
//		AntiTrackingManager.shared.trustDomain(domain: self.currentDomain ?? "")
		updateTrustButtonTooltip()
	}

	@IBAction func threedotsButtonPressed(sender: NSButton) {
		openSettings()
	}

	@IBAction func defaultConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToDefaultNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		} else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToCustomNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
		if !UserDefaults.standard.bool(forKey: SafariExtensionViewController.CustomSettingsSelectedKey) {
			self.openSettings()
			UserDefaults.standard.set(true, forKey: SafariExtensionViewController.CustomSettingsSelectedKey)
			UserDefaults.standard.synchronize()
		}
	}

	func updatePageLatency(_ url: String, _ latency: String) {
		self.currentUrl = url
	}

	private func openSettings() {
		// TODO: launchApplication also activates the app, with options it only runs but doesn't acitvates, in future find a way to launch and open  with corresponding menu without notification
//		let options = NSWorkspace.LaunchOptions(rawValue: 1000)
//		NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [options], additionalEventParamDescriptor: nil, launchIdentifier: nil)
//		NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [LaunchOptions], additionalEventParamDescriptor: <#T##NSAppleEventDescriptor?#>, launchIdentifier: AutoreleasingUnsafeMutablePointer<NSNumber?>?)
		NSWorkspace.shared.launchApplication("GhosteryLite")
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
			DistributedNotificationCenter.default().post(name: Constants.NavigateToSettingsNotificationName, object: "Gh.GhosteryLite.SafariExtension")
		}
	}

	private func updateTrustButtonState() {
		if let d = self.currentDomain {
			if AntiTrackingManager.shared.isTrustedDomain(domain: d) {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 1)
			} else {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 0)
			}
		}
		updateTrustButtonTooltip()
	}

	private func updateTrustButtonTooltip() {
		if trustSiteButton.state.rawValue == 0 {
			self.trustSiteButton?.toolTip = "Always allow trackers and ads on this site."
		} else {
			self.trustSiteButton?.toolTip = "Trackers and ads allowed. Click to undo."
		}
	}
}
