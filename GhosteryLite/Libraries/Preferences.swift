//
// Preferences
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

/// Static get/set methods for working with the UserDefaults database
class Preferences: NSObject {
	/// Check if the application has just been installed
	class func isNewInstall() -> Bool {
		return Preferences.getGlobalPreference(key: Constants.installDateKey) == nil
	}
	
	/// Use this to check if the application is launching for the first time. Different from isNewInstall() because
	/// here we wait until the entire application has finished launching. Preference `firstLaunchKey` is set
	/// once the user clicks out of the initial Enable Ghostery Lite modal (`hideEnableGhosteryLiteModal()`)
	class func isFirstLaunch() -> Bool {
		return !Preferences.getAppPreferenceBool(key: Constants.firstLaunchKey)
	}
	
	/// Check if the application has been updated
	class func isUpgrade() -> Bool {
		let lastVersion = Preferences.getGlobalPreference(key: Constants.lastVersionKey) as? String
		if lastVersion == nil || Utils.currentVersion() == lastVersion! {
			let lastBuildNumber = Preferences.getGlobalPreference(key: Constants.buildVersionKey) as? String
			return lastBuildNumber != nil && Utils.currentBuildNumber() != lastBuildNumber!
		}
		return true
	}

	/// Get a local user preference for the application
	/// - Parameter key: Preference key
	class func getAppPreference(key: String) -> Any? {
		return UserDefaults.standard.value(forKey: key)
	}
	
	/// Get a local user preference for the application, returned as a Bool
	/// - Parameter key: Preference key
	class func getAppPreferenceBool(key: String) -> Bool {
		return UserDefaults.standard.bool(forKey: key)
	}
	
	/// Set a local user preference for the application
	/// - Parameters:
	///   - key: Preference key
	///   - value: Preference value
	class func setAppPreference(key: String, value: Any) {
		UserDefaults.standard.set(value, forKey: key)
		UserDefaults.standard.synchronize()
	}
	
	/// Get a global user preference from the app group
	/// - Parameter key: Preference key
	class func getGlobalPreference(key: String) -> Any? {
		return UserDefaults(suiteName: Constants.AppsGroupID)?.value(forKey: key)
	}
	
	/// Get a global user preference from the app group, returned as a Bool
	/// - Parameter key: Preference key
	class func getGlobalPreferenceBool(key: String) -> Bool {
		return UserDefaults(suiteName: Constants.AppsGroupID)?.bool(forKey: key) ?? false
	}
	
	/// Save a global user preference to the app group
	/// - Parameters:
	///   - key: Stored preference key
	///   - value: Preference value
	class func setGlobalPreference(key: String, value: Any) {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		d?.set(value, forKey: key)
		d?.synchronize()
	}
}
