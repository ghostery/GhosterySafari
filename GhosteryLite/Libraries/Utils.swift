//
// Utils
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

/// Static utility functions available to all targets
class Utils {
	/// Custom debug logging function
	/// - Parameters:
	///   - object: The log message
	///   - filename: Source filename
	///   - line: Source line number
	///   - method: Source method name
	static func logger<T>(_ object: T, filename: String = #file, line: Int = #line, method: String = #function) {
		#if DEBUG
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let file = URL(string: filename)?.lastPathComponent ?? "" // extract the filename from the file path
			let className = file.replacingOccurrences(of: ".swift", with: "") // remove .swift extension
			let methodName = String(method[..<method.firstIndex(of: "(")!]) // remove method signature
			Swift.print("\(dateFormatter.string(from: Foundation.Date())) >> \(className).\(methodName):\(line) >> \(object)")
		#endif
	}
	
	/// Get the application current version
	static func currentVersion() -> String {
		if let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			return shortVersion
		}
		return ""
	}
	
	/// Get the application current build number
	static func currentBuildNumber() -> String {
		if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			return version
		}
		return ""
	}
	
	/// Convert a String of Int to [Int]
	/// - Parameter str: String of Ints
	static func stringToIntArray(_ str: String) -> [Int] {
		return str.compactMap{$0.wholeNumberValue}
	}
	
	/// Convert an [Int] to a sorted comma-separated String
	/// - Parameter arr: Array of Int
	static func intArrayToString(_ arr: [Int]) -> String {
		let sorted = arr.sorted()
		return sorted.map{String($0)}.joined(separator: ",")
	}
	
	/// Check to see if the applications extensions are currently enabled
	/// - Parameter completion: Callback handler
	static func areExtensionsEnabled(_ completion: @escaping(_ extensionsEnabled: Bool, _ error: Error?) -> Void) {
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
