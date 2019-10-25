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

import Cocoa

public enum MenuItem {
	case home
	case settings
	case trustedSites
	case help
	
	var title: String {
		switch self {
			case .home:
				return Strings.SideMenuHomeTitle
			case .settings:
				return Strings.SideMenuSettingsTitle
			case .trustedSites:
				return Strings.SideMenuTrustedSitesTitle
			case .help:
				return Strings.SideMenuHelpTitle
		}
	}
	
	var storyboardId: String {
		switch self {
			case .home:
				return "HomeViewController"
			case .settings:
				return "SettingsVC"
			case .trustedSites:
				return "TrustedSitesVC"
			case .help:
				return "HelpViewController"
		}
	}
	
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
	
	static func toArray() -> [MenuItem] {
		return [.home, .settings, .trustedSites, .help]
	}
}
