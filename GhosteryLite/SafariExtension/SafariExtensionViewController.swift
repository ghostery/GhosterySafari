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

	@IBOutlet weak var liteLabel: NSTextField!
	private var isPaused = false

	@IBOutlet weak var reloadPopupView: NSView!

	@IBOutlet weak var popupTitleLabel: NSTextField!

	@IBOutlet weak var popupReloadButton: NSButton!

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
		AntiTrackingManager.shared.configureRealm()
		setupComponents()
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
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: "Gh.GhosteryLite.SafariExtension")
			self.showPausedPopup()
		} else {
			self.pauseButton.toolTip = "Pause Ghostery Lite"
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: "Gh.GhosteryLite.SafariExtension")
			self.showResumedPopup()
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		d?.set(self.currentDomain ?? "", forKey: "domain")
		d?.synchronize()
		if sender.state.rawValue == 0 {
			DistributedNotificationCenter.default().post(name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
			self.showUntrustedPopup()
		} else {
			DistributedNotificationCenter.default().post(name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
			self.showTrustedPopup()
		}
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

	@IBAction func reloadePage(_ sender: Any) {
		self.reloadPopupView.isHidden = true
		SFSafariApplication.getActiveWindow(completionHandler: { (window) in
			window?.getActiveTab(completionHandler: { (tab) in
				tab?.getActivePage(completionHandler: { (page) in
					page?.reload()
				})
			})
		})
	}
	
	@IBAction func closePopup(_ sender: Any) {
		self.reloadPopupView.isHidden = true
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

	private func setupComponents() {
		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 18)
		self.defaultConfigRadio.font = NSFont(name: "OpenSans-Regular", size: 14)
		self.customConfigRadio.font = NSFont(name: "OpenSans-Regular", size: 14)
		self.urlLabel.font = NSFont(name: "OpenSans-Regular", size: 11)
		self.pageLatencyLabel.font = NSFont(name: "Roboto-Regular", size: 18)
		self.trustSiteButton.font = NSFont(name: "OpenSans-SemiBold", size: 11)
		self.popupTitleLabel.font = NSFont(name: "OpenSans-SemiBold", size: 11)
		self.popupReloadButton.font = NSFont(name: "OpenSans-SemiBold", size: 11)
	}

	private func showPausedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Ghostery Lite has been paused."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
//		self.reloadPopupView.layer?.backgroundColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1).cgColor
//		self.reloadPopupView.isHidden = false
	}

	private func showResumedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Ghostery Lite has been resumed."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showTrustedPopup() {
		let bgColor = NSColor(red: 0.156, green: 0.804, blue: 0.439, alpha: 1)
		let title = "Site whitelisted."
		showPopup(bgColor, title: title, fontColor: 0xffffff)
	}
	
	private func showUntrustedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Site no longer whitelisted."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showPopup(_ backgroundColor: NSColor, title: String, fontColor: Int) {
		self.reloadPopupView.layer?.backgroundColor = backgroundColor.cgColor
		self.popupTitleLabel.stringValue = title
		self.popupTitleLabel.textColor = NSColor(rgb: fontColor)
		self.popupReloadButton.attributedTitle = self.popupReloadButton.title.attributedString(withTextAlignment: .center,
																   fontName: "OpenSans-SemiBold",
																   fontSize: 11.0,
																   fontColor: fontColor)
//		self.popupReloadButton.bezelColor = fontColor
		self.reloadPopupView.isHidden = false
	}
}
