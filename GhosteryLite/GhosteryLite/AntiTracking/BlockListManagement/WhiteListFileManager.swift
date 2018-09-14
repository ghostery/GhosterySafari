//
//  WhiteListFileManager.swift
//  GhosteryLite
//
//  Created by Sahakyan on 9/14/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class WhiteListFileManager {

	static let shared: WhiteListFileManager = WhiteListFileManager()

	func add(_ domain: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			let rule = self.prepareRule(domain)
			let whitelist: [String : Any] = ["domain": domain, "active": self.canEnable(), "rule": rule]
			
			var whitelists: [[String:Any]]? = self.getAllRules() ?? []
			whitelists?.append(whitelist)
			self.save(whitelists)
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
	func remove(_ domain: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			let whitelists: [[String:Any]]? = self.getAllRules() ?? []
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

	func getActiveWhitelistRules() -> [[String:Any]]? {
		guard let whitelists = getAllRules() else { return [] }
		let activeWhitelists = whitelists.filter { (whitelist) -> Bool in
			return whitelist["active"] as? Bool ?? false
			}.compactMap { (activeWhitelist) -> [String: Any]? in
				return activeWhitelist["rule"] as? [String: Any]
		}
		return activeWhitelists
	}

	func getAllRules() -> [[String:Any]]? {
		let whitelists: [[String:Any]]? = FileManager.default.readJsonFile(at: self.getFilePath())
		return whitelists
	}

	private func getFilePath() -> URL? {
		let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
		let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
		return assetsFolder?.appendingPathComponent("trustedSitesList.json")
	}

	private func save(_ rules: [[String:Any]]?) {
		FileManager.default.writeJsonFile(at: self.getFilePath(), with: rules)
	}

	private func prepareRule(_ domain: String)  -> [String: Any] {
		let trigger: [String: Any] = ["url-filter": ".*", "if-domain": ["*\(domain)"]]
		let action = ["type": "ignore-previous-rules"]
		return ["trigger": trigger, "action": action]
	}

	private func canEnable() -> Bool {
		return true
	}
}
