//
// BlockListFileManager
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

final class BlockListFileManager {
	
	static let shared = BlockListFileManager()

	private let cliqzNetworkListChecksum = "cliqzNetworkListChecksum"
	private let cliqzCosmeticListChecksum = "cliqzCosmeticListChecksum"
	
	init() {}
	
	/// Check for new Block List versions on CDN and trigger an update if a newer version exists
	/// - Parameter done: callback handler
	func updateBlockLists(done: @escaping (Bool) -> ()) {
		var updated = false
		let group = DispatchGroup()
		
		// Fetch the Ghostery version file
		group.enter()
		DispatchQueue.main.async(group: group) {
			print("BlockListFileManager.updateBlockLists: Checking for Ghostery block list updates")
			DownloadManager.shared.downloadGhosteryVersionFile(completion: { (err, json) in
				if let blockListVersion = self.getGhosteryVersionNumber(json, key: Constants.GhosteryBlockListVersionKey) {
					// TODO: Check version numbers for each individual category file, rather than updating all categories if the master list version has changed
					if self.isGhosteryBlockListVersionChanged(blockListVersion, Constants.GhosteryBlockListVersionKey) {
						group.enter()
						// Update the complete block list file
						self.downloadAndSaveFile("safariContentBlocker", "", Constants.AssetsFolderURL) { () in
							Preferences.setGlobalPreference(key: Constants.GhosteryBlockListVersionKey, value: blockListVersion)
							updated = true
							group.leave()
						}
						
						// Update category block list files
						for type in CategoryType.allCases() {
							group.enter()
							self.downloadAndSaveFile(type.fileName(), "", Constants.AssetsFolderURL) { () in
								updated = true
								group.leave()
							}
						}
					} else {
						print("BlockListFileManager.updateBlockLists: No Ghostery block list updates available.")
					}
				}
				group.leave()
			})
		}
		
		// Fetch Cliqz ad block lists
		group.enter()
		DispatchQueue.main.async(group: group) {
			print("BlockListFileManager.updateBlockLists: Checking for Cliqz block list updates")
			DownloadManager.shared.downloadCliqzVersionFile(completion: { (err, json) in
				if let jsonData = json as? [String: Any], let safariObj = jsonData["safari"] as? [String: Any], let networkList = safariObj["network"] as? String, let cosmeticList = safariObj["cosmetic"] as? String {
					// Get the checksum value from the URL path
					let networkChecksum = self.getCliqzChecksum(networkList)
					let cosmeticChecksum = self.getCliqzChecksum(cosmeticList)
					
					if self.isCliqzBlockListChecksumChanged(networkChecksum, self.cliqzNetworkListChecksum) {
						group.enter()
						// Update the Cliqz network block list file
						self.downloadAndSaveFile("cliqzNetworkList", networkList, Constants.AssetsFolderURL) { () in
							Preferences.setGlobalPreference(key: self.cliqzNetworkListChecksum, value: networkChecksum)
							updated = true
							group.leave()
						}
					} else {
						print("BlockListFileManager.updateBlockLists: No Cliqz network filter list update available.")
					}
					
					if self.isCliqzBlockListChecksumChanged(cosmeticChecksum, self.cliqzCosmeticListChecksum) {
						group.enter()
						// Update the Cliqz cosmetic block list file
						self.downloadAndSaveFile("cliqzCosmeticList", cosmeticList, Constants.AssetsFolderURL) { () in
							Preferences.setGlobalPreference(key: self.cliqzCosmeticListChecksum, value: cosmeticChecksum)
							updated = true
							group.leave()
						}
					} else {
						print("BlockListFileManager.updateBlockLists: No Cliqz cosmetic filter list update available.")
					}
				}
				group.leave()
			})
		}
		
		group.notify(queue: .main) {
			done(updated)
		}
	}

	/// Combine all active block lists into currentBlockList.json
	/// - Parameter files: List of files to activate
	/// - Parameter completion: Completion callback
	func generateCurrentBlockList(files: [String], folderName: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			var blockListJSON = [[String: Any]]()
			// Build category lists into a single block list
			for f in files {
				if let url = Constants.AssetsFolderURL?.appendingPathComponent("\(f).json") {
					let nextChunk: [[String:Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						blockListJSON.append(contentsOf: n)
					}
				}
			}
			// Handle site whitelisting
			let whitelist = WhiteListFileManager.shared.getActiveWhitelistRules()
			let finalJSON: [[String: Any]] = blockListJSON + (whitelist ?? [])
			
			let currentBlockList = Constants.AssetsFolderURL?.appendingPathComponent("currentBlockList.json")
			FileManager.default.createDirectoryIfNotExists(Constants.AssetsFolderURL, withIntermediateDirectories: true)
			// Write the finalJSON to currentBlockList.json in the Container
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
	private func isGhosteryBlockListVersionChanged(_ newVersion: Int, _ oldVersionKey: String) -> Bool {
		if let oldVersion = Preferences.getGlobalPreference(key: oldVersionKey) as? Int {
			print("BlockListFileManager.isGhosteryBlockListVersionChanged: \(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
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
			print("BlockListFileManager.isCliqzBlockListChecksumChanged: \(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	/// Download block list json file and save to Group Container directory
	/// - Parameters:
	///   - fileName: The name of the json file
	///   - listType: The type of list (Cliqz or Ghostery)
	///   - folder: The folder location in Group Containers
	///   - done: Callback handler
	private func downloadAndSaveFile(_ fileName: String, _ listUrl: String, _ folder: URL?, done: @escaping () -> ()) {
		DownloadManager.shared.downloadBlockList(fileName, listUrl) { (err, data) in
			if let e = err {
				print("BlockListFileManager.downloadAndSaveFile: \(fileName) file download failed: \(e)")
			}
			if let d = data {
				// print("BlockListFileManager.downloadAndSaveFile: \(fileName)")
				FileManager.default.writeFile(d, name: "\(fileName).json", in: folder)
			}
			done()
		}
	}
	
	/// Get the Ghostery block list version number from JSON
	/// - Parameter json: The json data to scan
	/// - Parameter key: The key where the version resides
	private func getGhosteryVersionNumber(_ json: Any?, key: String) -> Int? {
		if let jsonData = json as? [String: Any] {
			return jsonData[key] as? Int
		}
		return nil
	}
	
	
	/// Extract the block list checksum from the list URL
	/// - Parameter listURL: The block list URL
	private func getCliqzChecksum(_ listURL: String) -> String {
		let l = listURL.replacingOccurrences(of: "https://cdn.cliqz.com/adblocker/safari/", with: "")
		return l.replacingOccurrences(of: "/rules.json", with: "")
	}
}
