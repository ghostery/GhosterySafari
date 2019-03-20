//
//  Preferences.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/28/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import SafariServices

class Preferences: NSObject {
	
	static let appFirstLaunchKey = "isAppLaunched"

    class func isAppFirstLaunch() -> Bool {
		return !UserDefaults.standard.bool(forKey: Preferences.appFirstLaunchKey)
    }

	class func firstLaunchFinished() {
		UserDefaults.standard.set(true, forKey: Preferences.appFirstLaunchKey)
		UserDefaults.standard.synchronize()
	}

	class func globalPreferences(key: String) -> Any? {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		return d?.value(forKey: key)
	}

	class func updateGlobalPreferences(key: String, value: Any) {
		let d = UserDefaults(suiteName: Constants.AppsGroupID)
		d?.set(value, forKey: key)
		d?.synchronize()
	}

	class func currentVersion() -> String {
		if let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			return shortVersion
		}
		return ""
	}

	class func currentBuildNumber() -> String {
		if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			return version
		}
		return ""
	}

    class func areExtensionsEnabled(_ completion: @escaping(_ contentBlockerEnabled: Bool, _ menuEnabled: Bool, _ error: Error?) -> Void) {
		var safariContentBlockerEnabled = false
		var safariMenuEnabled = false
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
				
				safariMenuEnabled = state.isEnabled
				group.leave()
			}
		}
		
		group.notify(queue: .main) {
			completion(safariContentBlockerEnabled, safariMenuEnabled, err)
		}
	}
}
