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

class BlockLists {
	
	static let shared = BlockLists()
	private let cliqzNetworkListChecksum = "cliqzNetworkListChecksum"
	private let cliqzCosmeticListChecksum = "cliqzCosmeticListChecksum"
	private struct ghosteryVersionData: Decodable {
		var safariContentBlockerVersion: Int
	}
	private struct clizVersionData: Decodable {
		let network, cosmetic: String
	}
	
	/// Check for new Block List versions on CDN and trigger an update if a newer version exists
	/// - Parameter done: callback handler
	func updateBlockLists(done: @escaping (Bool) -> ()) {
		var updated = false
		let group = DispatchGroup()
		
		// Fetch the Ghostery version file
		group.enter()
		DispatchQueue.main.async(group: group) {
			print("BlockLists.updateBlockLists: Checking for Ghostery block list updates")
			HTTPService.shared.getJSON(url: Constants.GhosteryAssetPath) { (completion: Result<ghosteryVersionData, HTTPService.HTTPServiceError>) in
				switch completion {
					case .success(let versionData):
						let blockListVersion = versionData.safariContentBlockerVersion
						// TODO: Check version numbers for each individual category file, rather than updating all categories if the master list version has changed
						if self.isGhosteryBlockListVersionChanged(blockListVersion, Constants.GhosteryBlockListVersionKey) {
							group.enter()
							// Update the complete block list file
							self.downloadAndSaveFile("safariContentBlocker", Constants.GhosteryAssetPath + "/safariContentBlocker", Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: Constants.GhosteryBlockListVersionKey, value: blockListVersion)
								updated = true
								group.leave()
							}
							
							// Update category block list files
							for type in Categories.allCases() {
								group.enter()
								self.downloadAndSaveFile(type.fileName(), Constants.GhosteryAssetPath + type.fileName(), Constants.AssetsFolderURL) { () in
									updated = true
									group.leave()
								}
							}
						} else {
							print("BlockLists.updateBlockLists: No Ghostery block list updates available.")
						}
					case .failure(let error):
						print("BlockLists.updateBlockLists error: \(error.localizedDescription)")
				}
				group.leave()
			}
		}
		
		// Fetch Cliqz ad block lists
		group.enter()
		DispatchQueue.main.async(group: group) {
			print("BlockLists.updateBlockLists: Checking for Cliqz block list updates")
			HTTPService.shared.getJSON(url: Constants.CliqzVersionPath) { (completion: Result<clizVersionData, HTTPService.HTTPServiceError>) in
				switch completion {
					case .success(let versionData):
						// Get the checksum value from the URL path
						let networkChecksum = self.getCliqzChecksum(versionData.network)
						let cosmeticChecksum = self.getCliqzChecksum(versionData.cosmetic)
						
						if self.isCliqzBlockListChecksumChanged(networkChecksum, self.cliqzNetworkListChecksum) {
							group.enter()
							// Update the Cliqz network block list file
							self.downloadAndSaveFile("cliqzNetworkList", versionData.network, Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: self.cliqzNetworkListChecksum, value: networkChecksum)
								updated = true
								group.leave()
							}
						} else {
							print("BlockLists.updateBlockLists: No Cliqz network filter list update available.")
						}
						
						if self.isCliqzBlockListChecksumChanged(cosmeticChecksum, self.cliqzCosmeticListChecksum) {
							group.enter()
							// Update the Cliqz cosmetic block list file
							self.downloadAndSaveFile("cliqzCosmeticList", versionData.cosmetic, Constants.AssetsFolderURL) { () in
								Preferences.setGlobalPreference(key: self.cliqzCosmeticListChecksum, value: cosmeticChecksum)
								updated = true
								group.leave()
							}
						} else {
							print("BlockLists.updateBlockLists: No Cliqz cosmetic filter list update available.")
					}
					case .failure(let error):
						print("BlockLists.updateBlockLists error: \(error.localizedDescription)")
				}
				group.leave()
			}
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
					let nextChunk: [[String: Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						blockListJSON.append(contentsOf: n)
					}
				}
			}
			// Handle site whitelisting
			let whitelist = WhiteList.shared.getActiveWhitelistRules()
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
			print("BlockLists.isGhosteryBlockListVersionChanged: \(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
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
			print("BlockLists.isCliqzBlockListChecksumChanged: \(oldVersionKey) Old version \(oldVersion) New version \(newVersion)")
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
					// print("BlockLists.downloadAndSaveFile: \(fileName)")
					FileManager.default.writeFile(jsonData, name: "\(fileName).json", in: folder)
				case .failure(let error):
					print("BlockLists.downloadAndSaveFile: \(fileName) file download failed: \(error.localizedDescription)")
			}
			done()
		}
	}
	
	/// Extract the block list checksum from the list URL
	/// - Parameter listURL: The block list URL
	private func getCliqzChecksum(_ listURL: String) -> String {
		let l = listURL.replacingOccurrences(of: "https://cdn.cliqz.com/adblocker/safari/", with: "")
		return l.replacingOccurrences(of: "/rules.json", with: "")
	}
}
