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

	@IBOutlet weak var liteLabel: NSTextField!
	@IBOutlet var pauseButton: NSButton!

	@IBOutlet var defaultConfigRadio: NSButton!
	@IBOutlet var customConfigRadio: NSButton!

	@IBOutlet var urlLabel: NSTextField!
	@IBOutlet var pageLatencyValueLabel: NSTextField!
	@IBOutlet var pageLatencyImage: NSImageView!
	@IBOutlet weak var pageLatencyDescLabel: NSTextField!
	
	@IBOutlet weak var firstRangeLabel: NSTextField!
	@IBOutlet weak var secondRangeLabel: NSTextField!
	@IBOutlet weak var thirdRangeLabel: NSTextField!
	@IBOutlet weak var secondsLabel: NSTextField!
	
	@IBOutlet weak var secondsLabelLeftOffset: NSLayoutConstraint!

	@IBOutlet var trustSiteButton: NSButton!

	@IBOutlet weak var reloadPopupView: NSView!
	@IBOutlet weak var popupTitleLabel: NSTextField!
	@IBOutlet weak var popupReloadButton: NSButton!
	@IBOutlet weak var popupCloseButton: NSButton!

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
			pageLatencyValueLabel?.stringValue = PageLatencyDataSource.shared.latencyFor(currentUrl ?? "")
			let params = PageLatencyDataSource.shared.latencyImageAndOffset(currentUrl ?? "")
			pageLatencyImage?.image = NSImage(named: NSImage.Name(params.0))
			secondsLabelLeftOffset.constant = params.1
//			pageLatencyImage?.image = NSImage(named: NSImage.Name(PageLatencyDataSource.shared.latencyImageName(currentUrl ?? "")))
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 302)
		let _ = AntiTrackingManager.shared
		setupComponents()
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		TelemetryManager.shared.sendSignal(.engage)
		self.view.layer?.backgroundColor = NSColor.white.cgColor
		urlLabel?.stringValue = self.currentDomain ?? ""
		if AntiTrackingManager.shared.isDefaultConfigEnabled() {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
		self.reloadPopupView.isHidden = true
	}

	@IBAction func pauseButtonPressed(sender: NSButton) {
		self.isPaused = sender.state.rawValue == 1
		if sender.state.rawValue == 1 {
			self.pauseButton.toolTip = "Resume Ghostery Lite"
			AntiTrackingManager.shared.pause()
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: Constants.SafariPopupExtensionID)
			self.trustSiteButton.isEnabled = false
			self.showPausedPopup()
		} else {
			self.pauseButton.toolTip = "Pause Ghostery Lite"
			AntiTrackingManager.shared.resume()
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: Constants.SafariPopupExtensionID)
			self.trustSiteButton.isEnabled = true
			self.showResumedPopup()
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		if let x = self.currentDomain {
			if sender.state.rawValue == 0 {
				AntiTrackingManager.shared.untrustDomain(domain: x)
				DistributedNotificationCenter.default().post(name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
				self.showUntrustedPopup()
			} else {
				AntiTrackingManager.shared.trustDomain(domain: x)
				DistributedNotificationCenter.default().post(name: Constants.TrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
				self.showTrustedPopup()
			}
		}
		updateTrustButtonTooltip()
	}

	@IBAction func threedotsButtonPressed(sender: NSButton) {
		openSettings()
	}

	@IBAction func defaultConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
			AntiTrackingManager.shared.switchToDefault()
		}/* else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}*/
	}

	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
			AntiTrackingManager.shared.switchToCustom()
		} /* else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}*/
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
			
			DistributedNotificationCenter.default().post(name: Constants.NavigateToSettingsNotificationName, object: Constants.SafariPopupExtensionID)
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
			self.trustSiteButton?.toolTip = "Trackers and ads allows. Click to undo."
		}
	}

	private func setupComponents() {
		let defaultStr = "Default Protection"
		self.defaultConfigRadio.attributedTitle = defaultStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: 0x4a4a4a)
		let customStr = "Custom Protection"
		self.customConfigRadio.attributedTitle = customStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: 0x4a4a4a)
		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 18)
//		self.defaultConfigRadio.font = NSFont(name: "OpenSans-Regular", size: 14)
////		self.customConfigRadio.font = NSFont(name: "OpenSans-Regular", size: 14)
////		self.customConfigRadio.stringValue = "Custom Protection"
////		self.customConfigRadio.title = "Hello"
		self.urlLabel.font = NSFont(name: "OpenSans-Regular", size: 11)
		self.pageLatencyValueLabel.font = NSFont(name: "Roboto-Regular", size: 18)
		self.pageLatencyDescLabel.font = NSFont(name: "OpenSans-Regular", size: 11)
		self.firstRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.secondRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.thirdRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.secondsLabel.font = NSFont(name: "Roboto-Regular", size: 9)
		self.popupTitleLabel.font = NSFont(name: "OpenSans-SemiBold", size: 11)
		self.popupReloadButton.font = NSFont(name: "OpenSans-SemiBold", size: 11)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.firstLineHeadIndent = 5.0
	}

	private func showPausedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Ghostery Lite has been paused."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showResumedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Ghostery Lite has been resumed."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showTrustedPopup() {
		let bgColor = NSColor(red: 0.156, green: 0.804, blue: 0.439, alpha: 1)
		let title = "Site whitelisted."
		showPopup(bgColor, title: title, fontColor: 0xffffff, image: "closePopupWhite")
	}
	
	private func showUntrustedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = "Site no longer whitelisted."
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showPopup(_ backgroundColor: NSColor, title: String, fontColor: Int, image: String = "closePopup") {
		self.reloadPopupView.layer?.backgroundColor = backgroundColor.cgColor
		self.popupTitleLabel.stringValue = title
		self.popupTitleLabel.textColor = NSColor(rgb: fontColor)
		self.popupReloadButton.attributedTitle = self.popupReloadButton.title.attributedString(withTextAlignment: .center,
																   fontName: "OpenSans-SemiBold",
																   fontSize: 11.0,
																   fontColor: fontColor, isUnderline: true)
		self.reloadPopupView.isHidden = false
		self.popupCloseButton.image = NSImage(named: NSImage.Name(image))
	}
}
