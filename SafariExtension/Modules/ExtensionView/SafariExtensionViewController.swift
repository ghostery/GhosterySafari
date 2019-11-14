//
// SafariExtensionViewController
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
	@IBOutlet weak var secondsLabelLeftOffset: NSLayoutConstraint?
	
	@IBOutlet var trustSiteButton: NSButton!
	@IBOutlet weak var reloadPopupView: NSView!
	@IBOutlet weak var popupTitleLabel: NSTextField!
	@IBOutlet weak var popupReloadButton: NSButton!
	@IBOutlet weak var popupCloseButton: NSButton!
	@IBOutlet weak var topHorizontalLine: NSView!
	@IBOutlet weak var middleHorizontalLine: NSView!
	
	private var isPaused = false

	private static let CustomSettingsSelectedKey = "CustomSettingsSelectedOnce"

	var currentDomain: String? {
		didSet {
			DispatchQueue.main.async {
				self.urlLabel?.stringValue = self.currentDomain ?? ""
				self.updateTrustButtonState()
			}
		}
	}

	var currentUrl: String? {
		didSet {
			DispatchQueue.main.async {
				self.pageLatencyValueLabel?.stringValue = PageLatencyDataSource.shared.latencyFor(self.currentUrl ?? "")
				let params = PageLatencyDataSource.shared.latencyImageAndOffset(self.currentUrl ?? "")
				self.pageLatencyImage?.image = NSImage(named: params.0)
				self.secondsLabelLeftOffset?.constant = params.1
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 302)
		setupComponents()
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		TelemetryManager.shared.sendSignal(.engage, ghostrank: 2)
		self.view.layer?.backgroundColor = NSColor(named: "backgroundColor")?.cgColor
		urlLabel?.stringValue = self.currentDomain ?? ""
		if ContentBlockerManager.shared.isDefaultConfigEnabled() {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
		updateReloadPopupViewVisibility(isHidden: true)
	}

	@IBAction func pauseButtonPressed(sender: NSButton) {
		self.isPaused = sender.state.rawValue == 1
		if sender.state.rawValue == 1 {
			self.pauseButton.toolTip = NSLocalizedString("button.resume.tooltip", comment: "Tooltip on resume button")
			ContentBlockerManager.shared.pause()
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: Constants.SafariPopupExtensionID)
			self.trustSiteButton.isEnabled = false
			self.showPausedPopup()
		} else {
			self.pauseButton.toolTip = NSLocalizedString("button.pause.tooltip", comment: "Tooltip on pause button")
			ContentBlockerManager.shared.resume()
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: Constants.SafariPopupExtensionID)
			self.trustSiteButton.isEnabled = true
			self.showResumedPopup()
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		if let x = self.currentDomain {
			if sender.state.rawValue == 0 {
				ContentBlockerManager.shared.untrustDomain(domain: x)
				DistributedNotificationCenter.default().post(name: Constants.UntrustDomainNotificationName, object: Constants.SafariPopupExtensionID)
				self.showUntrustedPopup()
			} else {
				ContentBlockerManager.shared.trustDomain(domain: x)
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
		if sender.state.rawValue == 1{
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
			ContentBlockerManager.shared.switchToDefault()
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
	}

	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
			ContentBlockerManager.shared.switchToCustom()
		} else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
		if !Preferences.getAppPreference(key: SafariExtensionViewController.CustomSettingsSelectedKey) {
			self.openSettings()
			Preferences.setAppPreference(key: SafariExtensionViewController.CustomSettingsSelectedKey, value: true)
		}
	}

	@IBAction func reloadePage(_ sender: Any) {
		updateReloadPopupViewVisibility(isHidden: true)
		SFSafariApplication.getActiveWindow(completionHandler: { (window) in
			window?.getActiveTab(completionHandler: { (tab) in
				tab?.getActivePage(completionHandler: { (page) in
					page?.reload()
				})
			})
		})
	}
	
	@IBAction func closePopup(_ sender: Any) {
		updateReloadPopupViewVisibility(isHidden: true)
	}

	func updatePageLatency(_ url: String, _ latency: String) {
		self.currentUrl = url
	}

	private func openSettings() {
		// TODO: launchApplication also activates the app, with options it only runs but doesn't activate, in future find a way to launch and open with corresponding menu without notification
		//	let options = NSWorkspace.LaunchOptions(rawValue: 1000)
		//	NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [options], additionalEventParamDescriptor: nil, launchIdentifier: nil)
		//	NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [LaunchOptions], additionalEventParamDescriptor: <#T##NSAppleEventDescriptor?#>, launchIdentifier: AutoreleasingUnsafeMutablePointer<NSNumber?>?)
		NSWorkspace.shared.launchApplication("GhosteryLite")
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
			DistributedNotificationCenter.default().post(name: Constants.NavigateToSettingsNotificationName, object: Constants.SafariPopupExtensionID)
		}
	}

	private func updateTrustButtonState() {
		if let d = self.currentDomain {
			if ContentBlockerManager.shared.isTrustedDomain(domain: d) {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 1)
			} else {
				self.trustSiteButton?.state = NSControl.StateValue(rawValue: 0)
			}
		}
		updateTrustButtonTooltip()
	}
	
	/// Update the Trust Site tooltip when trust state changes
	private func updateTrustButtonTooltip() {
		if trustSiteButton.state.rawValue == 0 {
			self.trustSiteButton?.toolTip = NSLocalizedString("trust.tooltip", comment: "Tooltip on Trust site button")
		} else {
			self.trustSiteButton?.toolTip = NSLocalizedString("trusted.tooltip", comment: "Tooltip on Trusted Site button")
		}
	}

	private func setupComponents() {
		let defaultStr = self.defaultConfigRadio.title
		self.defaultConfigRadio.attributedTitle = defaultStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: NSColor(named: "radioTextColor") ?? NSColor.white)
		let customStr = self.customConfigRadio.title
		self.customConfigRadio.attributedTitle = customStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: NSColor(named: "radioTextColor") ?? NSColor.white)

		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 18)
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
		
		let trustSiteTitle = self.trustSiteButton.title
		self.trustSiteButton?.attributedTitle = trustSiteTitle.attributedString(withTextAlignment: .center,
														fontName: "OpenSans-SemiBold",
														fontSize: 11.0,
														fontColor: NSColor(named: "trustBtnTitleColor") ?? NSColor.black,
														lineSpacing: 0)
		let siteTrustedTitle = NSLocalizedString("trusted.button", comment: "Trusted site button title")
		self.trustSiteButton?.attributedAlternateTitle = siteTrustedTitle.attributedString(withTextAlignment: .center,
															fontName: "OpenSans-SemiBold",
															fontSize: 11.0,
															fontColor:NSColor(named: "untrustBtnTitleColor") ?? NSColor.white,
															lineSpacing: 0)

		// TODO: refactor the method, not to call press action
		self.pauseButtonPressed(sender: self.pauseButton)
	}

	private func showPausedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("paused.message", comment: "Popup message after pausing Ghostery")
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showResumedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("resumed.message", comment: "Popup message after resuming Ghostery")
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showTrustedPopup() {
		let bgColor = NSColor(red: 0.156, green: 0.804, blue: 0.439, alpha: 1)
		let title = NSLocalizedString("whitelisted.message", comment: "Popup message after Trusting Site")
		showPopup(bgColor, title: title, fontColor: 0xffffff, image: "closePopupWhite")
	}
	
	private func showUntrustedPopup() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("untrusted.message", comment: "Popup message after Untrusting Site")
		showPopup(bgColor, title: title, fontColor: 0x4a4a4a)
	}

	private func showPopup(_ backgroundColor: NSColor, title: String, fontColor: Int, image: String = "closePopup") {
		self.reloadPopupView.layer?.backgroundColor = backgroundColor.cgColor
		let shadow =  NSShadow()
		shadow.shadowBlurRadius = 4
		shadow.shadowOffset = CGSize(width: 0, height: -2)
		shadow.shadowColor = NSColor(rgb: 0x969696, alpha: 0.5)
		self.reloadPopupView.shadow = shadow
		self.popupTitleLabel.stringValue = title
		self.popupTitleLabel.textColor = NSColor(rgb: fontColor)
		let reloadButton = self.popupReloadButton.title
		self.popupReloadButton.attributedTitle = reloadButton.attributedString(withTextAlignment: .center, fontName: "OpenSans-SemiBold", fontSize: 11.0, fontColor: NSColor(rgb: fontColor), isUnderline: true)
		updateReloadPopupViewVisibility(isHidden: false)
		self.popupCloseButton.image = NSImage(named: image)
	}
	
	private func updateReloadPopupViewVisibility(isHidden: Bool) {
		self.reloadPopupView.isHidden = isHidden
		self.defaultConfigRadio.isHidden = !isHidden
		self.customConfigRadio.isHidden = !isHidden
		self.topHorizontalLine.isHidden = !isHidden
		self.middleHorizontalLine.isHidden = !isHidden
	}
}
