//
// WhiteList
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

/// Maintains the trustedSitesList.json file on disk, which stores Whitelisted domains in Content Blocker format. The list
/// of trusted domains chosen by the user is stored in CoreData
class WhiteList {
	
	static let shared: WhiteList = WhiteList()
	
	/// Add a new rule to the whitelist
	/// - Parameters:
	///   - domain: The domain to whitelist
	///   - completion: Callback handler
	func add(_ domain: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			let rule = self.prepareRule(domain)
			let whitelist: [String: Any] = ["domain": domain, "active": true, "rule": rule]
			
			var whitelists: [[String: Any]]? = self.getAllRules() ?? []
			whitelists?.append(whitelist)
			self.save(whitelists)
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
	/// Remove a rule from the whitelist
	/// - Parameters:
	///   - domain: The domain to remove from the whitelist
	///   - completion: Callback handler
	func remove(_ domain: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			let whitelists: [[String: Any]]? = self.getAllRules() ?? []
			let newWhitelists = whitelists?.filter({ (whitelist) -> Bool in
				guard let nextDomain = whitelist["domain"] as? String else { return false }
				return domain != nextDomain
			})
			self.save(newWhitelists)
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
	/// Fetch all active Whitelist rules in Content Blocker format
	func getActiveWhitelistRules() -> [[String: Any]]? {
		guard let whitelists = getAllRules() else { return [] }
		let activeWhitelists = whitelists.filter { (whitelist) -> Bool in
			return whitelist["active"] as? Bool ?? false
		}.compactMap { (activeWhitelist) -> [String: Any]? in
			return activeWhitelist["rule"] as? [String: Any]
		}
		return activeWhitelists
	}
	
	/// Read Whitelist rules from disk
	private func getAllRules() -> [[String: Any]]? {
		let whitelists: [[String: Any]]? = FileManager.default.readJsonFile(at: self.getWhitelistFilePath())
		return whitelists
	}
	
	/// Locate the Whitelist json file on disk
	private func getWhitelistFilePath() -> URL? {
		return Constants.AssetsFolderURL?.appendingPathComponent("trustedSitesList.json")
	}
	
	/// Write the new whitelist to disk
	/// - Parameter rules: Whitelist rules in Content Blocker format
	private func save(_ rules: [[String: Any]]?) {
		FileManager.default.writeJsonFile(at: self.getWhitelistFilePath(), with: rules)
	}
	
	/// Build the block list rule into the Content Blocker format
	/// - Parameter domain: The domain to whitelist
	private func prepareRule(_ domain: String)  -> [String: Any] {
		let trigger: [String: Any] = ["url-filter": ".*",
									  "if-top-url": ["\(domain)"]]
		let action = ["type": "ignore-previous-rules"]
		return ["trigger": trigger, "action": action]
	}
}
