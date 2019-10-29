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
	
	
	//MARK:- Help Panel
	public static let HelpPanelText = NSLocalizedString("If you have encountered an issue, would like to know more about Ghostery Lite and our other products or would like to get in touch, please follow the link below.", comment: "[Help Panel] Help text")
	public static let HelpPanelSupportButtonTitle = NSLocalizedString("Ghostery Support", comment: "[Help Panel] Ghostery Support button title")
	public static let HelpPanelProductsButtonTitle = NSLocalizedString("Ghostery Products", comment: "[Help Panel] Ghostery Products button title")
	public static let HelpPanelBlogButtonTitle = NSLocalizedString("Ghostery Blog", comment: "[Help Panel] Ghostery Blog button title")
	public static let HelpPanelFaqsButtonTitle = NSLocalizedString("Ghostery FAQs", comment: "[Help Panel] Ghostery FAQs button title")
	
	
	
	//MARK:- Trusted Sites Panel
	public static let TrustedSitesPanelText = NSLocalizedString("All the sites that you trust can be seen here. You can also add or remove additional sites from your list using the field below.", comment: "[Trusted Sites Panel] Trusted Sites text")
	public static let TrustedSitesPanelTrustSiteButtonTitle = NSLocalizedString("TRUST SITE", comment: "[Trusted Sites Panel] Trust site button title")
	public static let TrustedSitesPanelErrorMessage = NSLocalizedString("Please enter a valid URL.", comment: "Error message in case if entered URL is invalid")
}
