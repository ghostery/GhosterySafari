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
	/// Application IDs
	static let GhosteryLiteID = "com.ghostery.lite"
	static let SafariContentBlockerID = "com.ghostery.lite.contentBlocker"
	static let SafariPopupExtensionID = "com.ghostery.lite.safariExtension"
	static let AppsGroupID = "HPY23A294X.ghostery.lite"
	
	/// Block list storage
	static let BlockListAssetsFolder = "BlockListAssets"
	static let GroupStorageFolderURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
	static let AssetsFolderURL: URL? = Constants.GroupStorageFolderURL?.appendingPathComponent(Constants.BlockListAssetsFolder, isDirectory: true)
	static let GhosteryBlockListVersionKey = "safariContentBlockerVersion"
	
	/// Block List CDN paths
	#if PROD
		static let GhosteryAssetPath = "https://cdn.ghostery.com/update/safari"
	#else
		static let GhosteryAssetPath = "https://staging-cdn.ghostery.com/update/safari"
	#endif
	
	#if PROD
		static let GhosteryVersionPath = "https://cdn.ghostery.com/update/version"
	#else
		static let GhosteryVersionPath = "https://staging-cdn.ghostery.com/update/version"
	#endif
	static let CliqzVersionPath = "https://cdn.cliqz.com/adblocker/configs/safari-ads/allowed-lists.json"
	
	/// Telemetry paths
	#if PROD
		static let telemetryAPIURL = "https://d.ghostery.com"
	#else
		static let telemetryAPIURL = "https://staging-d.ghostery.com"
	#endif
	
	/// Observer notifications
	static let PauseNotificationName = Notification.Name(rawValue: "GhosteryIsPaused")
	static let ResumeNotificationName = Notification.Name(rawValue: "GhosteryIsResumed")
	static let SwitchToDefaultNotificationName = Notification.Name(rawValue: "SwitchToDefaultConfig")
	static let SwitchToCustomNotificationName = Notification.Name(rawValue: "SwitchToCustomConfig")
	static let TrustDomainNotificationName = Notification.Name(rawValue: "TrustDomain")
	static let UntrustDomainNotificationName = Notification.Name(rawValue: "UntrustDomain")
	static let NavigateToSettingsNotificationName = Notification.Name(rawValue: "NavigateToSettings")
}
