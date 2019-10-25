//
// MainViewController
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

class MainViewController: NSViewController {
	
	fileprivate var menuViewController: MenuViewController? = nil
	fileprivate var detailViewController: DetailViewController? = nil
	fileprivate var modalViewController: ModalViewController? = nil
	
	@IBOutlet weak var overlayView: NSBox!
	@IBOutlet weak var liteLabel: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if Preferences.isAppFirstLaunch() {
			overlayView.isHidden = false
		}
		// TelemetryService.shared.sendSignal()
		
		ContentBlockerManager.shared.subscribeForNotifications()
		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 24)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "MenuViewController" {
			self.menuViewController = segue.destinationController as? MenuViewController
			self.menuViewController?.delegate = self
		} else if segue.identifier == "DetailViewController" {
			self.detailViewController = segue.destinationController as? DetailViewController
			self.detailViewController?.delegate = self
		} else if segue.identifier == "ModalViewController" {
			self.modalViewController = segue.destinationController as? ModalViewController
			self.modalViewController?.delegate = self
		}
	}
	
}

extension MainViewController : MenuViewControllerDelegate {
	func menuViewController(_ vc: MenuViewController, didSelectSectionItem item: MenuItem) {
		detailViewController?.switchToViewController(withStoryboardId: item.storyboardId)
	}
}

extension MainViewController : DetailViewControllerDelegate {
	func showSettingsPanel() {
		self.menuViewController?.selectItem(menuItem: .settings)
		// self.switchToViewController(withStoryboardId: MenuItem.settings.storyboardId)
	}
	
	func showTrustedSitesPanel() {
		self.menuViewController?.selectItem(menuItem: .trustedSites)
		// self.switchToViewController(withStoryboardId: MenuItem.trustedSites.storyboardId)
	}
}

extension MainViewController : ModalViewControllerDelegate {
	func hideSafariExtensionPopOver() {
		overlayView.isHidden = true
		Preferences.firstLaunchFinished()
	}
}

