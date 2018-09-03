//
//  Constants.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/17/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

struct Constants {

	static let SafariContentBlockerID = "Gh.GhosteryLite.ContentBlocker"
	static let SafariPopupExtensionID = "Gh.GhosteryLite.SafariExtension"

	static let AppsGroupID = "2UYYSSHVUH.Gh.GhosteryLite"

	static let PauseNotificationName = Notification.Name(rawValue: "GhosteryIsPaused")
	static let ResumeNotificationName = Notification.Name(rawValue: "GhosteryIsResumed")
	static let SwitchToDefaultNotificationName = Notification.Name(rawValue: "SwitchToDefaultConfig")
	static let SwitchToCustomNotificationName = Notification.Name(rawValue: "SwitchToCustomConfig")
	static let DomainChangedNotificationName = Notification.Name(rawValue: "TabDomainChanged")

}
