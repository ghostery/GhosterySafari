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
	private var isPaused = false
	
	/// The current webpage domain
	public var currentDomain: String? {
		didSet {
			DispatchQueue.main.async {
				self.urlLabel?.stringValue = self.currentDomain ?? ""
				self.updateTrustButtonState()
			}
		}
	}
	
	/// The current webpage URL
	public var currentUrl: String? {
		didSet {
			DispatchQueue.main.async {
				self.pageLatencyValueLabel?.stringValue = PageLatency.shared.latencyFor(self.currentUrl ?? "")
				let params = PageLatency.shared.latencyImageAndOffset(self.currentUrl ?? "")
				self.pageLatencyImage?.image = NSImage(named: params.0)
				self.secondsLabelLeftOffset?.constant = params.1
			}
		}
	}
	
	/// Outlets
	@IBOutlet weak var liteLabel: NSTextField!
	@IBOutlet var pauseButton: NSButton!
	@IBOutlet weak var topHorizontalLine: NSView!
	@IBOutlet weak var middleHorizontalLine: NSView!
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
	
	/// Notifications
	@IBOutlet weak var notificationView: NSView!
	@IBOutlet weak var notificationTitleLabel: NSTextField!
	@IBOutlet weak var notificationReloadButton: NSButton!
	@IBOutlet weak var notificationCloseButton: NSButton!

	/// Action taken when the pause button is pressed
	/// - Parameter sender: Pause button
	@IBAction func pauseButtonPressed(sender: NSButton) {
		self.isPaused = sender.state.rawValue == 1
		if sender.state.rawValue == 1 {
			self.pauseButton.toolTip = NSLocalizedString("button.resume.tooltip", comment: "Tooltip on resume button")
			GhosteryApplication.shared.pause()
			DistributedNotificationCenter.default().post(name: Constants.PauseNotificationName, object: Constants.SafariExtensionID)
			self.trustSiteButton.isEnabled = false
			self.showPausedNotification()
		} else {
			self.pauseButton.toolTip = NSLocalizedString("button.pause.tooltip", comment: "Tooltip on pause button")
			GhosteryApplication.shared.resume()
			DistributedNotificationCenter.default().post(name: Constants.ResumeNotificationName, object: Constants.SafariExtensionID)
			self.trustSiteButton.isEnabled = true
			self.showResumedNotification()
		}
	}
	
	/// Action taken when the Trust Site button is pressed
	/// - Parameter sender: Trust Site button
	@IBAction func trustButtonPressed(sender: NSButton) {
		if let x = self.currentDomain {
			if sender.state.rawValue == 0 {
				GhosteryApplication.shared.untrustDomain(domain: x)
				DistributedNotificationCenter.default().post(name: Constants.UntrustDomainNotificationName, object: Constants.SafariExtensionID)
				self.showUntrustedNotification()
			} else {
				GhosteryApplication.shared.trustDomain(domain: x)
				DistributedNotificationCenter.default().post(name: Constants.TrustDomainNotificationName, object: Constants.SafariExtensionID)
				self.showTrustedNotification()
			}
		}
		updateTrustButtonTooltip()
	}
	
	/// Action taken when the menu icon is pressed
	/// - Parameter sender: The menu icon
	@IBAction func threeDotsButtonPressed(sender: NSButton) {
		openSettings()
	}
	
	/// Action taken when the Default Blocking radio button is selected
	/// - Parameter sender: Radio button
	@IBAction func defaultConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1{
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariExtensionID)
			GhosteryApplication.shared.switchToDefaultBlocking()
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
	}
	
	/// Action taken when the Custom Blocking radio button is pressed
	/// - Parameter sender: Radio button
	@IBAction func customConfigPressed(sender: NSButton) {
		if sender.state.rawValue == 1 {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			DistributedNotificationCenter.default().post(name: Constants.SwitchToCustomNotificationName, object: Constants.SafariExtensionID)
			GhosteryApplication.shared.switchToCustomBlocking()
		} else {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}

		// Open app settings when the user clicks Custom Protection, but only the first time
		if !Preferences.getGlobalPreferenceBool(key: "CustomSettingsSelected") {
			self.openSettings()
			Preferences.setGlobalPreference(key: "CustomSettingsSelected", value: true)
		}
	}
	
	/// Action taken when the Reload Page link is pressed
	/// - Parameter sender: Reload button
	@IBAction func reloadPage(_ sender: Any) {
		notificationViewVisibility(isHidden: true)
		SFSafariApplication.getActiveWindow(completionHandler: { (window) in
			window?.getActiveTab(completionHandler: { (tab) in
				tab?.getActivePage(completionHandler: { (page) in
					page?.reload()
				})
			})
		})
	}
	
	/// Action taken when the notification close  button is pressed
	/// - Parameter sender: Close button
	@IBAction func closeNotification(_ sender: Any) {
		notificationViewVisibility(isHidden: true)
	}
	
	/// Called after the view controller’s view has been loaded into memory
	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 302)
		setupComponents()
	}
	
	/// Called after the view controller’s view has been loaded into memory is about to be added to the view hierarchy in the window
	override func viewWillAppear() {
		super.viewWillAppear()
		self.view.layer?.backgroundColor = NSColor(named: "backgroundColor")?.cgColor
		urlLabel?.stringValue = self.currentDomain ?? ""
		if GhosteryApplication.shared.isDefaultBlockingEnabled() {
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 1)
		} else {
			self.defaultConfigRadio.state = NSControl.StateValue(rawValue: 0)
			self.customConfigRadio.state = NSControl.StateValue(rawValue: 1)
		}
		notificationViewVisibility(isHidden: true)
	}
	
	/// Update the page latency value
	/// - Parameters:
	///   - url: The current page URL
	///   - latency: The current latency for the page
	func updatePageLatency(_ url: String, _ latency: String) {
		self.currentUrl = url
	}
	
	/// Open Ghostery Lite application settings
	private func openSettings() {
		// TODO: launchApplication also activates the app, with options it only runs but doesn't activate, in future find a way to launch and open with corresponding menu without notification
		//	let options = NSWorkspace.LaunchOptions(rawValue: 1000)
		//	NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [options], additionalEventParamDescriptor: nil, launchIdentifier: nil)
		//	NSWorkspace.shared.launchApplication(withBundleIdentifier: Constants.GhosteryLiteID, options: [LaunchOptions], additionalEventParamDescriptor: <#T##NSAppleEventDescriptor?#>, launchIdentifier: AutoreleasingUnsafeMutablePointer<NSNumber?>?)
		NSWorkspace.shared.launchApplication("GhosteryLite")
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
			DistributedNotificationCenter.default().post(name: Constants.NavigateToSettingsNotificationName, object: Constants.SafariExtensionID)
		}
	}
	
	/// Update the current state for the Trust Site button
	private func updateTrustButtonState() {
		if let d = self.currentDomain {
			if GhosteryApplication.shared.isDomainTrusted(domain: d) {
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
	
	/// Setup font and paragraph styling
	private func setupComponents() {
		let defaultStr = self.defaultConfigRadio.title
		let customStr = self.customConfigRadio.title
		let trustSiteTitle = self.trustSiteButton.title
		let siteTrustedTitle = NSLocalizedString("trusted.button", comment: "Trusted site button title")
		
		self.defaultConfigRadio.attributedTitle = defaultStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: NSColor(named: "radioTextColor") ?? NSColor.white)
		self.customConfigRadio.attributedTitle = customStr.attributedString(withTextAlignment: .left, fontName: "OpenSans-Regular", fontSize: 14, fontColor: NSColor(named: "radioTextColor") ?? NSColor.white)
		self.trustSiteButton?.attributedTitle = trustSiteTitle.attributedString(withTextAlignment: .center, fontName: "OpenSans-SemiBold", fontSize: 11.0, fontColor: NSColor(named: "trustBtnTitleColor") ?? NSColor.black, lineSpacing: 0)
		self.trustSiteButton?.attributedAlternateTitle = siteTrustedTitle.attributedString(withTextAlignment: .center, fontName: "OpenSans-SemiBold", fontSize: 11.0, fontColor:NSColor(named: "untrustBtnTitleColor") ?? NSColor.white, lineSpacing: 0)
		
		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 18)
		self.urlLabel.font = NSFont(name: "OpenSans-Regular", size: 11)
		self.pageLatencyValueLabel.font = NSFont(name: "Roboto-Regular", size: 18)
		self.pageLatencyDescLabel.font = NSFont(name: "OpenSans-Regular", size: 11)
		self.firstRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.secondRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.thirdRangeLabel.font = NSFont(name: "OpenSans-Regular", size: 10)
		self.secondsLabel.font = NSFont(name: "Roboto-Regular", size: 9)
		self.notificationTitleLabel.font = NSFont(name: "OpenSans-SemiBold", size: 11)
		self.notificationReloadButton.font = NSFont(name: "OpenSans-SemiBold", size: 11)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.firstLineHeadIndent = 5.0

		// TODO: refactor the method, not to call press action
		self.pauseButtonPressed(sender: self.pauseButton)
	}
	
	/// Show paused notification message
	private func showPausedNotification() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("paused.message", comment: "Notification message after pausing Ghostery")
		self.showNotificationView(bgColor, title: title, fontColor: NSColor(rgb: 0x4a4a4a))
	}
	
	/// Show resume notification message
	private func showResumedNotification() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("resumed.message", comment: "Notification message after resuming Ghostery")
		self.showNotificationView(bgColor, title: title, fontColor: NSColor(rgb: 0x4a4a4a))
	}
	
	/// Show site trusted notification message
	private func showTrustedNotification() {
		let bgColor = NSColor(red: 0.156, green: 0.804, blue: 0.439, alpha: 1)
		let title = NSLocalizedString("whitelisted.message", comment: "Notification message after Trusting Site")
		self.showNotificationView(bgColor, title: title, fontColor: NSColor.white, image: "closeButtonWhite")
	}
	
	/// Show site untrusted notification message
	private func showUntrustedNotification() {
		let bgColor = NSColor(red: 0.976, green: 0.929, blue: 0.745, alpha: 1)
		let title = NSLocalizedString("untrusted.message", comment: "Notification message after Untrusting Site")
		self.showNotificationView(bgColor, title: title, fontColor: NSColor(rgb: 0x4a4a4a))
	}
	
	/// Display the notification view
	/// - Parameters:
	///   - backgroundColor: View background color
	///   - title: Notification title
	///   - fontColor: Font color
	///   - image: Close button image
	private func showNotificationView(_ backgroundColor: NSColor, title: String, fontColor: NSColor, image: String = "closeButton") {
		self.notificationView.layer?.backgroundColor = backgroundColor.cgColor
		let shadow =  NSShadow()
		shadow.shadowBlurRadius = 4
		shadow.shadowOffset = CGSize(width: 0, height: -2)
		shadow.shadowColor = NSColor(rgb: 0x969696, alpha: 0.5)
		self.notificationView.shadow = shadow
		self.notificationTitleLabel.stringValue = title
		self.notificationTitleLabel.textColor = fontColor
		let reloadButton = self.notificationReloadButton.title
		self.notificationReloadButton.attributedTitle = reloadButton.attributedString(withTextAlignment: .center, fontName: "OpenSans-SemiBold", fontSize: 11.0, fontColor: fontColor, isUnderline: true)
		notificationViewVisibility(isHidden: false)
		self.notificationCloseButton.image = NSImage(named: image)
	}
	
	/// Set the visibility of the notification view
	/// - Parameter isHidden: Is the view hidden
	private func notificationViewVisibility(isHidden: Bool) {
		self.notificationView.isHidden = isHidden
		self.defaultConfigRadio.isHidden = !isHidden
		self.customConfigRadio.isHidden = !isHidden
		self.topHorizontalLine.isHidden = !isHidden
		self.middleHorizontalLine.isHidden = !isHidden
	}
}
