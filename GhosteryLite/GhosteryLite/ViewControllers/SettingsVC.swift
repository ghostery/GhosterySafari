//
//  ViewController.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import SafariServices

class SettingsVC: NSViewController {

	@IBOutlet weak var topTextLabel: NSTextField!
	@IBOutlet var defaultRadio: NSButton!
	@IBOutlet weak var defaultDescLabel: NSTextField!

	@IBOutlet var customRadio: NSButton!
	@IBOutlet weak var customDescLabel: NSTextField!

	@IBOutlet var groupBox: NSBox!
	@IBOutlet var adCheckbox: NSButton!
	@IBOutlet var siteAnalyticsCheckbox: NSButton!
	@IBOutlet var customInterCheckbox: NSButton!
	@IBOutlet var socialMediaCheckbox: NSButton!
	@IBOutlet var essentialCheckbox: NSButton!
	@IBOutlet var audioVideoCheckbox: NSButton!
	@IBOutlet var adultCheckbox: NSButton!
	@IBOutlet var commentsCheckbox: NSButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateRadioBoxesState),
															name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().addObserver(self,
															selector: #selector(self.updateRadioBoxesState),
															name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		setupComponents()
		updateCategoryCheckboxStates()
		SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "Gh.GhosteryLite.ContentBlocker") { (state, error) in
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	deinit {
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToDefaultNotificationName, object: Constants.SafariPopupExtensionID)
		DistributedNotificationCenter.default().removeObserver(self, name: Constants.SwitchToCustomNotificationName, object: Constants.SafariPopupExtensionID)
	}

	@IBAction func categoryPressed(sender: NSButton) {
		var modifiedCat: CategoryType?
		switch sender.tag {
		case 1:
			modifiedCat = .advertising
			print("Supported category")
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
		case 9:
			modifiedCat = .uncategorized
		default:
			print("Unsupported category")
		}
		if let m = modifiedCat {
			let _ = GlobalConfigManager.shared.changeCategoryStatus(m, status: sender.state.rawValue == 0 ? false : true)
			AntiTrackingManager.shared.reloadContentBlocker()
		}
	}

	@IBAction func defaultSelected(_ sender: Any) {
		AntiTrackingManager.shared.switchToDefault()
		self.customRadio.state = NSControl.StateValue(rawValue: 0)
		self.groupBox.isHidden = true
	}

	@IBAction func customSelected(_ sender: Any) {
		AntiTrackingManager.shared.switchToCustom()
		self.defaultRadio.state = NSControl.StateValue(rawValue: 0)
		self.groupBox.isHidden = false
	}

	private func setupComponents() {
		self.updateRadioBoxesState()
		self.topTextLabel.font = NSFont(name: "Roboto-Regular", size: 16)
		self.defaultRadio.font = NSFont(name: "Roboto-Bold", size: 14)
		self.customRadio.font = NSFont(name: "Roboto-Bold", size: 14)
		self.defaultDescLabel.font = NSFont(name: "Roboto-Regular", size: 14)
		self.customDescLabel.font = NSFont(name: "Roboto-Regular", size: 14)
		adCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		audioVideoCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		commentsCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		customInterCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		essentialCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		adultCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		siteAnalyticsCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
		socialMediaCheckbox.font = NSFont(name: "Roboto-Regular", size: 14)
	}

	@objc
	private func updateRadioBoxesState() {
		if AntiTrackingManager.shared.isDefaultConfigEnabled() {
			self.defaultRadio.state = NSControl.StateValue(rawValue: 1)
			self.customRadio.state = NSControl.StateValue(rawValue: 0)
			self.groupBox.isHidden = true
		} else {
			self.defaultRadio.state = NSControl.StateValue(rawValue: 0)
			self.customRadio.state = NSControl.StateValue(rawValue: 1)
			self.groupBox.isHidden = false
		}
	}

	private func updateCategoryCheckboxStates() {
		adCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.advertising) ? 1 : 0)
		audioVideoCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.audioVideoPlayer) ? 1 : 0)
		commentsCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.comments) ? 1 : 0)
		customInterCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.customerInteraction) ? 1 : 0)
		essentialCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.essential) ? 1 : 0)
		adultCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.pornvertising) ? 1 : 0)
		siteAnalyticsCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.siteAnalytics) ? 1 : 0)
		socialMediaCheckbox.state = NSControl.StateValue(GlobalConfigManager.shared.isCategoryBlocked(.socialMedia) ? 1 : 0)
	}
}

