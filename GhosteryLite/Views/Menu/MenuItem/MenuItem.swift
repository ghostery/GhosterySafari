//
// MenuItem
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

import Foundation

/// Current Ghostery menu options
enum MenuItem: CaseIterable {
	case home
	case settings
	case trustedSites
	case help
	
	/// Localized menu titles
	var title: String {
		switch self {
			case .home:
				return NSLocalizedString("home.menu", comment: "Home panel title in the side menu")
			case .settings:
				return NSLocalizedString("settings.menu", comment: "Settings panel title in the side menu")
			case .trustedSites:
				return NSLocalizedString("trusted.sites.menu", comment: "Trusted Sites panel title in the side menu")
			case .help:
				return NSLocalizedString("help.menu", comment: "Help panel title in the side menu")
		}
	}
	
	/// Maps the menu item to it's storyboard view controller
	var storyboardId: String {
		switch self {
			case .home:
				return "HomeViewController"
			case .settings:
				return "SettingsViewController"
			case .trustedSites:
				return "TrustedSitesViewController"
			case .help:
				return "HelpViewController"
		}
	}
	
	/// Maps the menu item to it's icon
	/// - Parameter active: Is the menu icon active
	func iconName(active: Bool) -> String {
		var iconName = ""
		switch self {
			case .home:
				iconName += "home"
			case .settings:
				iconName += "settings"
			case .trustedSites:
				iconName += "trusted"
			case .help:
				iconName += "help"
		}
		
		if active {
			return "\(iconName)-active"
		}
		
		return "\(iconName)-inactive"
	}
	
	/// Returns an array of all MenuItem cases
	static func allMenuItemCases() -> [MenuItem] {
		return MenuItem.allCases.map{$0}
	}
}
