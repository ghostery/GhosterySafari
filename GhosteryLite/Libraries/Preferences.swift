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
import SafariServices

class Preferences: NSObject {
	/// Check if the application has just been installed
	class func isNewInstall() -> Bool {
		return Preferences.getGlobalPreference(key: Constants.installDateKey) == nil
	}
	
	/// Use this to check is the application is launching for the first time. Different from isNewInstall() because here we wait until the entire application has finished launching.
	class func isFirstLaunch() -> Bool {
		return !self.getAppPreferenceBool(key: Constants.firstLaunchKey)
	}
	
	/// Check if the application has been updated
	class func isUpgrade() -> Bool {
		let lastVersion = Preferences.getGlobalPreference(key: Constants.lastVersionKey) as? String
		if lastVersion == nil || Preferences.currentVersion() == lastVersion! {
			let lastBuildNumber = Preferences.getGlobalPreference(key: Constants.buildVersionKey) as? String
			return lastBuildNumber != nil && Preferences.currentBuildNumber() != lastBuildNumber!
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
	
	/// Get the application current version
	class func currentVersion() -> String {
		if let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			return shortVersion
		}
		return ""
	}
	
	/// Get the application current build number
	class func currentBuildNumber() -> String {
		if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			return version
		}
		return ""
	}
	
	/// Check to see if the applications extensions are currently enabled
	/// - Parameter completion: Callback handler
	class func areExtensionsEnabled(_ completion: @escaping(_ extensionsEnabled: Bool, _ error: Error?) -> Void) {
		let group = DispatchGroup()
		var err: Error?
		var enabled = false
		
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: Constants.SafariExtensionID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				enabled = state.isEnabled
				group.leave()
			}
		}
		
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: Constants.SafariContentBlockerID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				enabled = state.isEnabled
				group.leave()
			}
		}
		
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: Constants.SafariContentBlockerCosmeticID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				enabled = state.isEnabled
				group.leave()
			}
		}
		
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: Constants.SafariContentBlockerNetworkID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				enabled = state.isEnabled
				group.leave()
			}
		}
		
		group.notify(queue: .main) {
			completion(enabled, err)
		}
	}
}
