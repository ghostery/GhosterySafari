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
	
	//MARK:- Home Panel
	public static let HomePanelTitle = NSLocalizedString("Welcome to Ghostery Lite!", comment: "[Home panel] Title")
	public static let HomePanelSubtitle = NSLocalizedString("Thanks for installing Ghostery Lite. You are now protected with our default settings!", comment: "[Home panel] Subtitle")
	public static let HomePanelSettingsDescriptionPrefix = NSLocalizedString("Want to customize your tracker settings?", comment: "[Home panel] Edit settings text prefix")
	public static let HomePanelSettingsDescription = NSLocalizedString("Select the tracker categories you would like to block or unblock.", comment: "[Home panel] Edit settings text")
	public static let HomePanelEditSettingsButtonTitle = NSLocalizedString("EDIT SETTINGS", comment: "[Home panel] Edit settings button title")
	public static let HomePanelTrustedSitesDescriptionPrefix = NSLocalizedString("Want to allow trackers on a site?", comment: "[Home panel] Trusted sites text prefix")
	public static let HomePanelTrustedSitesDescription = NSLocalizedString(" Add or remove sites from your 'Trusted' list.", comment: "[Home panel] Trusted sites text")
	public static let HomePanelTrustedSitesButtonTitle = NSLocalizedString("TRUSTED SITES", comment: "[Home panel] Trusted sites button title")
	public static let HomePanelEnableGhosteryLitePromptText = NSLocalizedString("Please enable the Ghostery Lite extensions in your Safari preferences to begin.", comment: "[Home panel] Enable Ghostery Lite prompt text")
	public static let HomePanelEnableGhosteryLiteButtonTitle = NSLocalizedString("ENABLE LITE", comment: "[Home panel] Enable Ghostery Lite button title")
	
	//MARK:- Sttings Panel
	public static let SettingsPanelTitle = NSLocalizedString("With Ghostery Lite's default settings you're protected and ready to browse. If you want to change your tracker-blocker settings, our custom settings allow you to block or unblock specific categories of trackers and ads.", comment: "Settings panel")
	public static let SettinsPanelDefault = NSLocalizedString("Default", comment: "Default radio title")
	public static let SettinsPanelCustom = NSLocalizedString("Custom", comment: "Custom radio title")
	public static let SettinsPanelAdvertising = NSLocalizedString("Block: Advertising", comment: "Advertising category checkbox")
	public static let SettinsPanelAnalytics = NSLocalizedString("Block: Site Analytics", comment: "Analytics category checkbox")
	public static let SettinsPanelCustomer = NSLocalizedString("Block: Customer Interaction", comment: "Customer Interaction category checkbox")
	public static let SettinsPanelMedia = NSLocalizedString("Block: Social Media", comment: "Social Media category checkbox")
	public static let SettinsPanelEssential = NSLocalizedString("Block: Essential", comment: "Essential category checkbox")
	public static let SettinsPanelAudioVideo = NSLocalizedString("Block: Audio/Video Player", comment: "Audio/Video category checkbox")
	public static let SettinsPanelAdult = NSLocalizedString("Block: Adult Content", comment: "Adult Content category checkbox")
	public static let SettinsPanelComments = NSLocalizedString("Block: Comments", comment: "Comments category checkbox")
	public static let SettinsPanelSaved = NSLocalizedString("Saved", comment: "Notification on Custom configuration change")
	
	public static let SettingsPanelDefaultDescription = NSLocalizedString("Ghostery Lite’s default settings have been tailored to provide the cleanest, fastest and safest browsing experience, allowing you to focus on exploring your favorite websites and online content. We block advertising, site analytics and adult advertising trackers.", comment: "Description test on Settings pannel for Default settings")
	public static let SettingsPanelCustomDescription = NSLocalizedString("Select the tracker categories that you would like to block or unblock. Please note that some sites may not load correctly depending on your custom settings.", comment: "Description test on Settings pannel for Custom settings")
	public static let LearnMore = NSLocalizedString("Learn more", comment: "Link to learn more web page")
	
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
