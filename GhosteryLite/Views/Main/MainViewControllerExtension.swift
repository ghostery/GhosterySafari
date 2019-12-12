//
// MainViewControllerExtension
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

extension MainViewController: MenuViewControllerDelegate {
	func menuViewController(_ vc: MenuViewController, didSelectSectionItem item: MenuItem) {
		detailViewController?.switchToViewController(withStoryboardId: item.storyboardId)
	}
}

extension MainViewController: DetailViewControllerDelegate {
	func showSettingsPanel() {
		self.menuViewController?.selectItem(menuItem: .settings)
	}
	
	func showTrustedSitesPanel() {
		self.menuViewController?.selectItem(menuItem: .trustedSites)
	}
}

extension MainViewController: ModalViewControllerDelegate {
	func hideSafariExtensionPopOver() {
		overlayView.isHidden = true
		Preferences.firstLaunchFinished()
	}
}
