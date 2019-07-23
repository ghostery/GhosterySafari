//
//  Strings.swift
//  SafariExtension
//
//  Created by Sahakyan on 10/31/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

public struct Strings {

	public static let DefaultConfigTitle = NSLocalizedString("Default Protection", comment: "Default config radio text")
	public static let CustomConfigTitle = NSLocalizedString("Custom Protection", comment: "Custom config radio text")
	
	public static let SecondsTitle = NSLocalizedString("seconds", comment: "Seconds: text below speed range")
	public static let LatencyDescription = NSLocalizedString("seconds load time", comment: "Latency Description")
	public static let TrustActionTitle = NSLocalizedString("Trust Site", comment: "Trust Site button title")
	public static let UntrustActionTitle = NSLocalizedString("Site Trusted", comment: "Untrust Site button title")

	public static let ResumeTooltip = NSLocalizedString("Resume Ghostery Lite", comment: "Tooltip on resume button")
	public static let PauseTooltip = NSLocalizedString("Pause Ghostery Lite", comment: "Tooltip on pause button")
	public static let TrustSiteTooltip = NSLocalizedString("Always allow trackers and ads on this site.", comment: "Tooltip on Trust site button")
	public static let UntrustSiteTooltip = NSLocalizedString("Trackers and ads allows. Click to undo.", comment: "Tooltip on Untrust site button")

	public static let PausedPopupMessage = NSLocalizedString("Ghostery Lite has been paused.", comment: "Popup message after pausing Ghostery")
	public static let ResumedPopupMessage = NSLocalizedString("Ghostery Lite has been resumed.", comment: "Popup message after resuming Ghostery")
	public static let TrustedPopupMessage = NSLocalizedString("Site whitelisted.", comment: "Popup message after Trusting Site")
	public static let UntrustedPopupMessage = NSLocalizedString("Site no longer whitelisted.", comment: "Popup message after Untrusting Site")
	public static let ReloadPopupButtonTitle = NSLocalizedString("Reload To See Changes", comment: "Text on reload button")

	public static let CustomConfigInfoTooltip = NSLocalizedString("Control which categories of tracker you block/allow in your custom settings.", comment: "Tooltip on info icon of Custom configuration")
}
