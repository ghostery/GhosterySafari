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

import Cocoa
import SafariServices

class Preferences: NSObject {
	
	static let appFirstLaunchKey = "isAppLaunched"
	
	/// Is this the first launch of the application?
	class func isAppFirstLaunch() -> Bool {
		return !(self.getAppPreference(key: Preferences.appFirstLaunchKey) != nil)
	}
	
	/// Set preferences to track the initial application launch
	class func firstLaunchFinished() {
		self.setAppPreference(key: Preferences.appFirstLaunchKey, value: true)
	}
	
	/// Get a local user preference for the application
	/// - Parameter key: Preference key
	class func getAppPreference(key: String) -> Any? {
		return UserDefaults.standard.value(forKey: key)
	}
	
	/// Set a local user preference for the application
	/// - Parameters:
	///   - key: Preference key
	///   - value: Preference value
	class func setAppPreference(key: String, value: Any) {
		UserDefaults.standard.set(value, forKey: key)
		UserDefaults.standard.synchronize()
	}
	
	/// Fetch a global user preference from the app group
	/// - Parameter key: Stored preference key
	class func getGlobalPreference(key: String) -> Any? {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		return d?.value(forKey: key)
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
	class func areExtensionsEnabled(_ completion: @escaping(_ contentBlockerEnabled: Bool, _ popoverEnabled: Bool, _ error: Error?) -> Void) {
		var safariContentBlockerEnabled = false
		var safariExtensionEnabled = false
		let group = DispatchGroup()
		var err: Error?
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: Constants.SafariContentBlockerID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				safariContentBlockerEnabled = state.isEnabled
				group.leave()
			}
		}
		
		group.enter()
		DispatchQueue.main.async(group: group) {
			SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: Constants.SafariPopupExtensionID) { (state, error) in
				guard let state = state else {
					err = error
					group.leave()
					return
				}
				
				safariExtensionEnabled = state.isEnabled
				group.leave()
			}
		}
		
		group.notify(queue: .main) {
			completion(safariContentBlockerEnabled, safariExtensionEnabled, err)
		}
	}
}
