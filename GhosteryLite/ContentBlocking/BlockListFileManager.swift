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
	
	private static let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
	private static let assetsFolder: URL? = BlockListFileManager.groupStorageFolder?.appendingPathComponent("BlockListAssets")
	private static let categoryAssetsFolder: URL? = BlockListFileManager.assetsFolder?.appendingPathComponent("BlockListByCategory")
	private static let blockListVersionKey = "safariContentBlockerVersion"
	private static let categoryBlockListVersionKey = "safariCategoryVersion"
	
	static let shared = BlockListFileManager()
	
	init() {}
	
	/// Check for new Block List versions on CDN and trigger an update if a newer version exists
	/// - Parameter done: callback handler
	func updateBlockLists(done: @escaping (Bool) -> ()) {
		print("BlockListFileManager.updateBlockLists: Checking for block list updates...")
		var updated = false
		let group = DispatchGroup()
		// Fetch the version file
		FileDownloader.shared.downloadBlockListVersion(completion: { (err, json) in
			// Category block lists
			if let categoryListVersion = self.intValueFromJson(json, key: BlockListFileManager.categoryBlockListVersionKey) {
				if self.isCategoryBlockListVersionChanged(categoryListVersion) {
					// Update category block list files
					for type in CategoryType.allCases() {
						group.enter()
						self.downloadAndSaveFile(type.fileName(), BlockListFileManager.categoryAssetsFolder) { () in
							Preferences.updateGlobalPreferences(key: BlockListFileManager.categoryBlockListVersionKey, value: categoryListVersion)
							updated = true
							group.leave()
						}
					}
				} else {
					print("BlockListFileManager.updateBlockLists: No category updates available.")
				}
			}
			// Full block list
			if let blockListVersion = self.intValueFromJson(json, key: BlockListFileManager.blockListVersionKey) {
				if self.isFullBlockListVersionChanged(blockListVersion) {
					group.enter()
					// Update the complete block list file
					self.downloadAndSaveFile("safariContentBlocker", BlockListFileManager.assetsFolder) { () in
						Preferences.updateGlobalPreferences(key: BlockListFileManager.blockListVersionKey, value: blockListVersion)
						updated = true
						group.leave()
					}
				} else {
					print("BlockListFileManager.updateBlockLists: No Safari block list update available.")
				}
			}
			group.notify(queue: .main) {
				done(updated)
			}
		})
	}
	
	/// Fetch the path of the block list file from the Group Container folder
	/// - Parameter fileName: The name of the block list json file
	/// - Parameter folderName: The name of the assets folder in Group Containers
	func getFilePath(fileName: String, folderName: String) -> URL? {
		let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
		let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent(folderName)
		return assetsFolder?.appendingPathComponent("\(fileName).json")
	}
	
	/// Combine all active block lists into currentBlockList.json
	/// - Parameter files: List of files to activate
	/// - Parameter folderName: Folder location of the files
	/// - Parameter completion: Completion callback
	func generateCurrentBlockList(files: [String], folderName: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			var blockListJSON = [[String: Any]]()
			// Build category lists into a single block list
			for f in files {
				if let url = self.getFilePath(fileName: f, folderName: folderName) {
					let nextChunk: [[String:Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						blockListJSON.append(contentsOf: n)
					}
				}
			}
			// Handle site whitelisting
			let whitelist = WhiteListFileManager.shared.getActiveWhitelistRules()
			let finalJSON: [[String: Any]] = blockListJSON + (whitelist ?? [])
			
			let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
			let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
			let currentBlockList = assetsFolder?.appendingPathComponent("currentBlockList.json")
			FileManager.default.createDirectoryIfNotExists(assetsFolder, withIntermediateDirectories: true)
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
	
	/// Check to see if the category Block Lists have new versions available
	/// - Parameter newVersion: Version of the block list on the CDN
	private func isCategoryBlockListVersionChanged(_ newVersion: Int) -> Bool {
		if let oldVersion = Preferences.globalPreferences(key: BlockListFileManager.categoryBlockListVersionKey) as? Int {
			print("BlockListFileManager.isCategoryBlockListVersionChanged: Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	/// Check to see if the main compiled Block List has a new version available
	/// - Parameter newVersion: Version of the block list on the CDN
	private func isFullBlockListVersionChanged(_ newVersion: Int) -> Bool {
		if let oldVersion = Preferences.globalPreferences(key: BlockListFileManager.blockListVersionKey) as? Int {
			print("BlockListFileManager.isFullBlockListVersionChanged: Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	/// Download block list json file and save to Group Container directory
	/// - Parameters:
	///   - fileName: The name of the json file
	///   - folder: The folder location in Group Containers
	///   - done: Callback handler
	private func downloadAndSaveFile(_ fileName: String, _ folder: URL?, done: @escaping () -> ()) {
		FileDownloader.shared.downloadBlockList(fileName) { (err, data) in
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
	
	/// Get the Version int value from the JSON key
	/// - Parameter json: The json data to scan
	/// - Parameter key: The key where the int value resides
	private func intValueFromJson(_ json: Any?, key: String) -> Int? {
		if let jsonData = json as? [String: Any] {
			return jsonData[BlockListFileManager.blockListVersionKey] as? Int
		}
		return nil
	}
}
