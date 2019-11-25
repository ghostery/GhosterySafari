//
// DetailViewController
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

class DetailViewController: NSViewController {
	
	var delegate: DetailViewControllerDelegate?
	var viewControllers = [String: NSViewController]()
	
	@IBOutlet weak var container: NSView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		initViewControllers()
	}
	
	func switchToViewController(withStoryboardId storyboardId: String) {
		if let viewController = viewControllers[storyboardId] {
			removePreviousView()
			container.addSubview(viewController.view)
		}
	}
	
	private func initViewControllers() {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		
		for menuItem in MenuItem.toArray() {
			let storyboardId = menuItem.storyboardId
			let identifier = storyboardId
			if let viewController = storyboard.instantiateController(withIdentifier: identifier) as? NSViewController {
				viewControllers[storyboardId] = viewController
				
				if let homeViewController = viewController as? HomeViewController {
					homeViewController.delegate = self.delegate
				}
			}
		}
	}
	
	private func removePreviousView() {
		if let oldView: NSView = container.subviews.first {
			oldView.removeFromSuperview()
		}
	}
}
