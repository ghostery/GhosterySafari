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

/// Application globals
struct Constants {
	/// Application IDs
	static let GhosteryLiteID = "com.ghostery.lite"
	static let SafariContentBlockerID = "com.ghostery.lite.contentBlocker"
	static let SafariContentBlockerCosmeticID = "com.ghostery.lite.contentBlockerCosmetic"
	static let SafariContentBlockerNetworkID = "com.ghostery.lite.contentBlockerNetwork"
	static let SafariExtensionID = "com.ghostery.lite.safariExtension"
	static let AppsGroupID = "HPY23A294X.ghostery.lite"
	
	/// Preference keys
	static let firstLaunchKey = "firstLaunchCompleted"
	static let installDateKey = "installDate"
	static let installRandKey = "installRand"
	static let lastVersionKey = "lastVersion"
	static let buildVersionKey = "lastBuildVersion"
	static let coreDataMigrationCompleted = "CoreDataMigrationCompleted"
	
	/// Block list storage
	static let BlockListAssetsFolder = "BlockListAssets"
	static let GroupStorageFolderURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
	static let AssetsFolderURL: URL? = Constants.GroupStorageFolderURL?.appendingPathComponent(Constants.BlockListAssetsFolder, isDirectory: true)
	static let GhosteryBlockListVersionKey = "safariContentBlockerVersion"
	
	/// Content Blocker json lists and their associated bundle IDs
	enum ContentBlockerLists: String {
		case standard = "current_main.json"
		case cosmetic = "current_cosmetic.json"
		case network = "current_network.json"
		
		/// Return the bundle ID for the content blocker
		func getID() -> String {
			switch self {
				case .standard:
					return Constants.SafariContentBlockerID
				case .cosmetic:
					return Constants.SafariContentBlockerCosmeticID
				case .network:
					return Constants.SafariContentBlockerNetworkID
			}
		}
	}
	
	/// Block list json files
	static let TrustedSitesList = "trusted_sites.json"
	static let EmptyRulesList = "empty_rules"
	static let GhosteryBlockList = "safariContentBlocker"
	static let CliqzCosmeticList = "cliqzCosmeticList"
	static let CliqzCosmeticListChecksum = "cliqzCosmeticListChecksum"
	static let CliqzNetworkList = "cliqzNetworkList"
	static let CliqzNetworkListChecksum = "cliqzNetworkListChecksum"
	
	/// Block List CDN paths
	#if PROD
		static let GhosteryAssetPath = "https://cdn.ghostery.com/update/safari/"
	#else
		static let GhosteryAssetPath = "https://staging-cdn.ghostery.com/update/safari/"
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
