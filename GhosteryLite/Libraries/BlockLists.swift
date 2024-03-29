//
// BlockLists
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

/// Handles all functions related to maintaining block list files. Checks for list updates, generates a new
/// active list and reloads the Content Blocker.
class BlockLists {
	
	static let shared = BlockLists()

	private struct ghosteryVersionData: Decodable {
		var safariContentBlocker: String
	}
	private struct cliqzVersionData: Decodable {
		let safari: cliqzSafariLists
	}
	private struct cliqzSafariLists: Decodable {
		let network, cosmetic: String
	}
	
	/// Check for new Block List versions on CDN and trigger an update if a newer version exists
	/// - Parameter done: callback handler
	func updateBlockLists(done: @escaping (Bool) -> ()) {
		var updated = false
		let group = DispatchGroup()
		
		// Check for DB updates daily
		if !self.isTimeForDBUpdate() {
			Utils.logger("Already checked for DB updates today")
			return
		}
		
		// Fetch the Ghostery version file
		group.enter()
		DispatchQueue.main.async(group: group) {
			Utils.logger("Checking for Ghostery block list updates")
			HTTPService.shared.getJSON(url: Constants.GhosteryVersionPath) { (completion: Result<ghosteryVersionData, HTTPService.HTTPServiceError>) in
				switch completion {
					case .success(let versionData):
						let blockListVersion = versionData.safariContentBlocker
						// TODO: Check version numbers for each individual category file, rather than updating all categories if the master list version has changed
						if self.isGhosteryBlockListVersionChanged(blockListVersion, Constants.GhosteryBlockListVersionKey) {
							group.enter()
							// Update the complete block list file
							self.downloadAndSaveFile(Constants.GhosteryBlockList, Constants.GhosteryAssetPath + "/safariContentBlocker", Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: Constants.GhosteryBlockListVersionKey, value: blockListVersion)
								updated = true
								group.leave()
							}
							
							// Update category block list files
							for type in Categories.allCategories() {
								group.enter()
								self.downloadAndSaveFile(type.fileName(), Constants.GhosteryAssetPath + type.fileName(), Constants.AssetsFolderURL) { () in
									updated = true
									group.leave()
								}
							}
						} else {
							Utils.logger("No Ghostery block list updates available.")
						}
					case .failure(let error):
						Utils.logger("Ghostery version error: \(error)")
				}
				group.leave()
			}
		}
		
		// Fetch Cliqz ad block lists
		group.enter()
		DispatchQueue.main.async(group: group) {
			Utils.logger("Checking for Cliqz block list updates")
			HTTPService.shared.getJSON(url: Constants.CliqzVersionPath) { (completion: Result<cliqzVersionData, HTTPService.HTTPServiceError>) in
				switch completion {
					case .success(let versionData):
						// Get the checksum value from the URL path
						let networkChecksum = self.getCliqzChecksum(versionData.safari.network)
						let cosmeticChecksum = self.getCliqzChecksum(versionData.safari.cosmetic)
						
						if self.isCliqzBlockListChecksumChanged(networkChecksum, Constants.CliqzNetworkListChecksum) {
							group.enter()
							// Update the Cliqz network block list file
							self.downloadAndSaveFile(Constants.CliqzNetworkList, versionData.safari.network, Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: Constants.CliqzNetworkListChecksum, value: networkChecksum)
								updated = true
								group.leave()
							}
						} else {
							Utils.logger("No Cliqz network filter list update available.")
						}
						
						if self.isCliqzBlockListChecksumChanged(cosmeticChecksum, Constants.CliqzCosmeticListChecksum) {
							group.enter()
							// Update the Cliqz cosmetic block list file
							self.downloadAndSaveFile(Constants.CliqzCosmeticList, versionData.safari.cosmetic, Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: Constants.CliqzCosmeticListChecksum, value: cosmeticChecksum)
								updated = true
								group.leave()
							}
						} else {
							Utils.logger("No Cliqz cosmetic filter list update available.")
					}
					case .failure(let error):
						Utils.logger("Cliqz version error: \(error)")
				}
				group.leave()
			}
		}
		
		group.notify(queue: .main) {
			done(updated)
		}
	}
	
	/// Generate the current block list for the appropriate Content Blocker
	/// - Parameters:
	///   - files: List of files to activate
	///   - blockListFile: The output block list json file
	///   - completion: Callback handler
	func generateCurrentBlockList(files: [String], blockListFile: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			var blockListJSON = [[String: Any]]()
			// Build category lists into a single block list
			for f in files {
				if let url = Constants.AssetsFolderURL?.appendingPathComponent("\(f).json") {
					let nextChunk: [[String: Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						blockListJSON.append(contentsOf: n)
					}
				}
			}
			// Handle site whitelisting
			let whitelist = WhiteList.shared.getActiveWhitelistRules()
			let finalJSON: [[String: Any]] = blockListJSON + (whitelist ?? [])
			
			let currentBlockList = Constants.AssetsFolderURL?.appendingPathComponent(blockListFile)
			FileManager.default.createDirectoryIfNotExists(Constants.AssetsFolderURL, withIntermediateDirectories: true)
			// Write the finalJSON to blockListFile json in the App Group
			if let url = currentBlockList {
				try? FileManager.default.removeItem(at: url)
				FileManager.default.writeJsonFile(at: url, with: finalJSON)
			}
			DispatchQueue.main.async {
				completion()
			}
		}
	}
	
	/// Check to see if the Ghostery block list version number has changed
	/// - Parameter newVersion: The new version of the block list on the CDN
	/// - Parameter oldVersionKey The preference key where the old version number is stored
	private func isGhosteryBlockListVersionChanged(_ newVersion: String, _ oldVersionKey: String) -> Bool {
		if let oldVersion = Preferences.getGlobalPreference(key: oldVersionKey) as? String {
			Utils.logger("\(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	/// Check to see if the Cliqz block list checksum has changed
	/// - Parameters:
	///   - newVersion: The new checksum value
	///   - oldVersionKey: The preference key where the old checksum value is stored
	private func isCliqzBlockListChecksumChanged(_ newVersion: String, _ oldVersionKey: String) -> Bool {
		if let oldVersion = Preferences.getGlobalPreference(key: oldVersionKey) as? String {
			Utils.logger("\(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	/// Download block list json data and save to Group Container directory
	/// - Parameters:
	///   - fileName: The name of the json file to write to disk
	///   - listUrl: The URL of the list to download
	///   - folder: The folder location in Group Containers
	///   - done: Callback handler
	private func downloadAndSaveFile(_ fileName: String, _ listUrl: String, _ folder: URL?, done: @escaping () -> ()) {
		HTTPService.shared.getJSONData(url: listUrl) { (completion: Result<Data, HTTPService.HTTPServiceError>) in
			switch completion {
				case .success(let jsonData):
					// Utils.logger("Downloaded \(fileName)")
					FileManager.default.writeFile(jsonData, name: "\(fileName).json", in: folder)
				case .failure(let error):
					Utils.logger("\(fileName) file download failed: \(error)")
			}
			done()
		}
	}
	
	/// Extract the block list checksum from the list URL
	/// - Parameter listURL: The block list URL
	private func getCliqzChecksum(_ listURL: String) -> String {
		let l = listURL.replacingOccurrences(of: "https://cdn.ghostery.com/adblocker/safari/", with: "")
		return l.replacingOccurrences(of: "/rules.json", with: "")
	}
	
	/// Limit DB updates to once per day
	private func isTimeForDBUpdate() -> Bool {
		if let lastChecked = Preferences.getGlobalPreference(key: "dbUpdateCheck") as? Date {
			// Have we already checked for DB updates today?
			if Calendar.current.isDateInToday(lastChecked) {
				return false
			}
		}
		Preferences.setGlobalPreference(key: "dbUpdateCheck", value: Date())
		return true
	}
}
