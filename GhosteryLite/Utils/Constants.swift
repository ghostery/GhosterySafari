//
// Constants
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

struct Constants {
	
	static let GhosteryLiteID = "com.ghostery.lite"
	static let SafariContentBlockerID = "com.ghostery.lite.contentBlocker"
	static let SafariPopupExtensionID = "com.ghostery.lite.safariExtension"
	
	static let AppsGroupID = "HPY23A294X.ghostery.lite"
	
	static let BlockListAssetsFolder = "BlockListAssets"
	static let GroupStorageFolderURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
	static let AssetsFolderURL: URL? = Constants.GroupStorageFolderURL?.appendingPathComponent(Constants.BlockListAssetsFolder, isDirectory: true)
	static let GhosteryBlockListVersionKey = "safariContentBlockerVersion"
	
	static let PauseNotificationName = Notification.Name(rawValue: "GhosteryIsPaused")
	static let ResumeNotificationName = Notification.Name(rawValue: "GhosteryIsResumed")
	static let SwitchToDefaultNotificationName = Notification.Name(rawValue: "SwitchToDefaultConfig")
	static let SwitchToCustomNotificationName = Notification.Name(rawValue: "SwitchToCustomConfig")
	static let DomainChangedNotificationName = Notification.Name(rawValue: "TabDomainChanged")
	static let TrustDomainNotificationName = Notification.Name(rawValue: "TrustDomain")
	static let UntrustDomainNotificationName = Notification.Name(rawValue: "UntrustDomain")
	static let NavigateToSettingsNotificationName = Notification.Name(rawValue: "NavigateToSettings")
	
}
