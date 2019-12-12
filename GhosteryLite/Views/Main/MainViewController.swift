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
	
	var menuViewController: MenuViewController? = nil
	var detailViewController: DetailViewController? = nil
	var modalViewController: ModalViewController? = nil
	
	@IBOutlet weak var overlayView: NSBox!
	@IBOutlet weak var liteLabel: NSTextField!
	
	/// Called after the view controller’s view has been loaded into memory
	override func viewDidLoad() {
		super.viewDidLoad()
		if Preferences.isAppFirstLaunch() {
			overlayView.isHidden = false
		}
		
		GhosteryApplication.shared.subscribeForNotifications()
		self.liteLabel.font = NSFont(name: "BebasNeueBook", size: 24)
	}
	
	/// Called when a segue is about to be performed
	/// - Parameters:
	///   - segue: The segue object containing information about the view controllers involved in the segue
	///   - sender: The object that initiated the segue
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
