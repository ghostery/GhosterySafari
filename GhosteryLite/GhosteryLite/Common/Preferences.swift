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
