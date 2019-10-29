//
// Strings
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

public struct Strings {
	//MARK:- Side Menu
	public static let SideMenuHomeTitle = NSLocalizedString("Home", comment: "Home panel title in the side menu")
	public static let SideMenuSettingsTitle = NSLocalizedString("Settings", comment: "Settings panel title in the side menu")
	public static let SideMenuTrustedSitesTitle = NSLocalizedString("Trusted Sites", comment: "Trusted Sites panel title in the side menu")
	public static let SideMenuHelpTitle = NSLocalizedString("Help", comment: "Help panel title in the side menu")
	
	//MARK:- Safari Extension Prompt
	public static let SafariExtensionPromptText = NSLocalizedString("Please enable Ghostery Lite Icon and Ghostery Lite extensions in your Safari preferences to begin.", comment: "[Safari Extension Prompt] text")
	public static let SafariExtensionPromptEnableGhosteryLiteButtonTitle = NSLocalizedString("ENABLE GHOSTERY LITE", comment: "[Safari Extension Prompt]] Enable Ghostery Lite button title")
	public static let SafariExtensionPromptSkipButtonTitle = NSLocalizedString("Skip for now", comment: "[Safari Extension Prompt] skip for now button title")
}
