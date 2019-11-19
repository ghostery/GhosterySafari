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

class WhiteList {
	
	static let shared: WhiteList = WhiteList()
	
	func add(_ domain: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			let rule = self.prepareRule(domain)
			let whitelist: [String: Any] = ["domain": domain, "active": self.canEnable(), "rule": rule]
			
			var whitelists: [[String: Any]]? = self.getAllRules() ?? []
			whitelists?.append(whitelist)
			self.save(whitelists)
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
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
	
	func getActiveWhitelistRules() -> [[String: Any]]? {
		guard let whitelists = getAllRules() else { return [] }
		let activeWhitelists = whitelists.filter { (whitelist) -> Bool in
			return whitelist["active"] as? Bool ?? false
		}.compactMap { (activeWhitelist) -> [String: Any]? in
			return activeWhitelist["rule"] as? [String: Any]
		}
		return activeWhitelists
	}
	
	func getAllRules() -> [[String: Any]]? {
		let whitelists: [[String: Any]]? = FileManager.default.readJsonFile(at: self.getWhitelistFilePath())
		return whitelists
	}
	
	private func getWhitelistFilePath() -> URL? {
		return Constants.AssetsFolderURL?.appendingPathComponent("trustedSitesList.json")
	}
	
	private func save(_ rules: [[String: Any]]?) {
		FileManager.default.writeJsonFile(at: self.getWhitelistFilePath(), with: rules)
	}
	
	private func prepareRule(_ domain: String)  -> [String: Any] {
		let trigger: [String: Any] = ["url-filter": ".*",
									  "if-top-url": ["\(domain)"]]
		let action = ["type": "ignore-previous-rules"]
		return ["trigger": trigger, "action": action]
	}
	
	private func canEnable() -> Bool {
		return true
	}
}
