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
		return !UserDefaults.standard.bool(forKey: Preferences.appFirstLaunchKey)
	}
	
	/// Set preferences to track the initial application launch
	class func firstLaunchFinished() {
		UserDefaults.standard.set(true, forKey: Preferences.appFirstLaunchKey)
		UserDefaults.standard.synchronize()
	}
	
	/// Fetch a user preference from memory
	/// - Parameter key: Stored preference key
	class func getPreference(key: String) -> Any? {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		return d?.value(forKey: key)
	}
	
	/// Save a user preference to memory
	/// - Parameters:
	///   - key: Stored preference key
	///   - value: Preference value
	class func setPreference(key: String, value: Any) {
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
