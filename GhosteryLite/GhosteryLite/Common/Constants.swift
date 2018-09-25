//
//  Constants.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/17/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

struct Constants {

	static let GhosteryLiteID = "com.ghostery.lite"
	static let SafariContentBlockerID = "com.ghostery.lite.contentBlocker"
	static let SafariPopupExtensionID = "com.ghostery.lite.safariExtension"

	static let AppsGroupID = "HPY23A294X.ghostery.lite"

	static let PauseNotificationName = Notification.Name(rawValue: "GhosteryIsPaused")
	static let ResumeNotificationName = Notification.Name(rawValue: "GhosteryIsResumed")
	static let SwitchToDefaultNotificationName = Notification.Name(rawValue: "SwitchToDefaultConfig")
	static let SwitchToCustomNotificationName = Notification.Name(rawValue: "SwitchToCustomConfig")
	static let DomainChangedNotificationName = Notification.Name(rawValue: "TabDomainChanged")
	static let TrustDomainNotificationName = Notification.Name(rawValue: "TrustDomain")
	static let UntrustDomainNotificationName = Notification.Name(rawValue: "UntrustDomain")
	static let NavigateToSettingsNotificationName = Notification.Name(rawValue: "NavigateToSettings")

}
