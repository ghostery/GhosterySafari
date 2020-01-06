//
// SettingsViewController
// GhosteryLite
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

import Cocoa

class SettingsViewController: NSViewController {
	
	@IBOutlet weak var topTextLabel: NSTextField!
	@IBOutlet var defaultRadio: NSButton!
	@IBOutlet weak var defaultDescLabel: NSTextField!
	
	@IBOutlet var customRadio: NSButton!
	@IBOutlet weak var customDescLabel: NSTextField!
	
	@IBOutlet var categoryBox: NSBox!
	@IBOutlet var adCheckbox: NSButton!
	@IBOutlet var siteAnalyticsCheckbox: NSButton!
	@IBOutlet var customInterCheckbox: NSButton!
	@IBOutlet var socialMediaCheckbox: NSButton!
	@IBOutlet var essentialCheckbox: NSButton!
	@IBOutlet var audioVideoCheckbox: NSButton!
	@IBOutlet var adultCheckbox: NSButton!
	@IBOutlet var commentsCheckbox: NSButton!
	
	@IBOutlet var savedBox: NSBox!
	@IBOutlet var savedLabel: NSTextField!
	
	/// Action taken when a category checkbox is selected
	/// - Parameter sender: The category checkbox that was selected
	@IBAction func categoryPressed(sender: NSButton) {
		var modifiedCat: Categories?
		switch sender.tag {
			case 1:
				modifiedCat = .advertising
			case 2:
				modifiedCat = .audioVideoPlayer
			case 3:
				modifiedCat = .comments
			case 4:
				modifiedCat = .customerInteraction
			case 5:
				modifiedCat = .essential
			case 6:
				modifiedCat = .pornvertising
			case 7:
				modifiedCat = .siteAnalytics
			case 8:
				modifiedCat = .socialMedia
			default:
				Utils.logger("Unsupported category")
		}
		if let m = modifiedCat {
			let _ = BlockingConfiguration.shared.updateBlockedCategory(category: m, blocked: sender.state.rawValue == 0 ? false : true)
			GhosteryApplication.shared.reloadContentBlockers()
			self.savedBox.isHidden = false
		}
	}
	
	/// Action taken when the default configuration radio button is selected
	/// - Parameter sender: The default config radio button
	@IBAction func defaultSelected(_ sender: Any) {
		GhosteryApplication.shared.switchToDefaultBlocking()
		self.customRadio.state = NSControl.StateValue(rawValue: 0)
		self.categoryBox.isHidden = true
	}
	
	/// Action taken when the custom configuration radio button is selected
	/// - Parameter sender: The custom config radio button
	@IBAction func customSelected(_ sender: Any) {
		GhosteryApplication.shared.switchToCustomBlocking()
		self.defaultRadio.state = NSControl.StateValue(rawValue: 0)
		self.categoryBox.isHidden = false
		self.savedBox.isHidden = true
	}
	
	/// Called after the view controller’s view has been loaded into memory.
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupComponents()
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateRadioBoxesState), name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.updateRadioBoxesState), name: Constants.SwitchToCustomNotificationName, object: Constants.SafariExtensionID)
	}
	
	/// Called after the view controller’s view has been loaded into memory is about to be added to the view hierarchy in the window.
	override func viewWillAppear() {
		super.viewWillAppear()
		self.updateRadioBoxesState()
		self.updateCategoryCheckboxStates()
	}
	
	deinit {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToCustomNotificationName, object: Constants.SafariExtensionID)
	}
	
	/// Setup font and paragraph styling
	private func setupComponents() {
		let settingsTitle = self.topTextLabel.stringValue
		self.topTextLabel.attributedStringValue = settingsTitle.attributedString(withTextAlignment: .left, fontName: "Roboto-Regular", fontSize: 16, fontColor: NSColor.panelTextColor(), isUnderline: false, lineSpacing: 3)
		
		self.defaultRadio.font = NSFont(name: "Roboto-Bold", size: 14)
		self.customRadio.font = NSFont(name: "Roboto-Bold", size: 14)
		
		let learnMore = NSLocalizedString("learn.more.link", comment: "Link to learn more URL")
		self.setupTextField(textField: self.defaultDescLabel, mainText: self.defaultDescLabel.stringValue, learnMoreText: learnMore, urlString: "https://www.ghostery.com/faqs/")
		self.setupTextField(textField: self.customDescLabel, mainText: self.customDescLabel.stringValue, learnMoreText: learnMore, urlString: "https://www.ghostery.com/faqs/")
		
		adCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		audioVideoCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		commentsCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		customInterCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		essentialCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		adultCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		siteAnalyticsCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		socialMediaCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		self.savedLabel.textColor = NSColor(rgb: 0x67a73a)
		self.savedLabel.font = NSFont(name: "Roboto-Regular", size: 14)
		self.savedBox.isHidden = true
	}
	
	/// Update state of the blocking config radio boxes
	@objc private func updateRadioBoxesState() {
		if GhosteryApplication.shared.isDefaultBlockingEnabled() {
			self.defaultRadio.state = NSControl.StateValue(rawValue: 1)
			self.customRadio.state = NSControl.StateValue(rawValue: 0)
			self.categoryBox.isHidden = true
		} else {
			self.defaultRadio.state = NSControl.StateValue(rawValue: 0)
			self.customRadio.state = NSControl.StateValue(rawValue: 1)
			self.categoryBox.isHidden = false
		}
	}
	
	/// Update state of the blocking category checkboxes
	private func updateCategoryCheckboxStates() {
		adCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .advertising) ? 1 : 0)
		audioVideoCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .audioVideoPlayer) ? 1 : 0)
		commentsCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .comments) ? 1 : 0)
		customInterCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .customerInteraction) ? 1 : 0)
		essentialCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .essential) ? 1 : 0)
		adultCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .pornvertising) ? 1 : 0)
		siteAnalyticsCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .siteAnalytics) ? 1 : 0)
		socialMediaCheckbox.state = NSControl.StateValue(BlockingConfiguration.shared.isCategoryBlocked(category: .socialMedia) ? 1 : 0)
	}
	
	/// Builds text formatting for settings view copy
	/// - Parameters:
	///   - textField: The text field
	///   - mainText: The text as String
	///   - learnMoreText: Learn more text
	///   - urlString: Leran more URL
	private func setupTextField(textField: NSTextField, mainText: String, learnMoreText: String, urlString: String) {
		let textColor: NSColor = NSColor.panelTextColor()
		let textParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
		textParagraph.lineSpacing = 1
		textParagraph.maximumLineHeight = 30.0
		textParagraph.alignment = .left
		let font = NSFont(name: "Roboto-Regular", size: 14) ?? NSFont.systemFont(ofSize: 14)
		let attribs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.paragraphStyle: textParagraph]
		let str = "\(mainText) \(learnMoreText)"
		let attrString: NSMutableAttributedString = NSMutableAttributedString.init(string: str, attributes: attribs)
		let range = NSMakeRange(str.count - learnMoreText.count, learnMoreText.count)
		if let url = URL(string: urlString) {
			attrString.addAttribute(NSAttributedString.Key.link, value: url, range: range)
		}
		textField.attributedStringValue = attrString
	}
}
