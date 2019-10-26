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
import Alamofire

enum CategoryType: Int {
	case advertising
	case audioVideoPlayer
	case comments
	case customerInteraction
	case essential
	case pornvertising
	case siteAnalytics
	case socialMedia
	case uncategorized
	
	static func allCategoriesCount() -> Int {
		return 8
	}
	
	func fileName() -> String {
		switch self {
			case .advertising:
				return "cat_advertising"
			case .audioVideoPlayer:
				return "cat_audio_video_player"
			case .comments:
				return "cat_comments"
			case .customerInteraction:
				return "cat_customer_interaction"
			case .essential:
				return "cat_essential"
			case .pornvertising:
				return "cat_pornvertising"
			case .siteAnalytics:
				return "cat_site_analytics"
			case .socialMedia:
				return "cat_social_media"
			case .uncategorized:
				return "cat_unclassifed"
		}
	}
	
	static func allCases() -> [CategoryType] {
		return [.advertising, .audioVideoPlayer, .comments, .customerInteraction, .essential, .pornvertising, .siteAnalytics, .socialMedia, .uncategorized]
	}
}

final class BlockListFileManager {
	
	private static let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
	private static let assetsFolder: URL? = BlockListFileManager.groupStorageFolder?.appendingPathComponent("BlockListAssets")
	private static let categoryAssetsFolder: URL? = BlockListFileManager.assetsFolder?.appendingPathComponent("BlockListByCategory")
	private static let blockListVersionKey = "safariContentBlockerVersion"
	private static let categoryBlockListVersionKey = "safariCategoryVersion"
	
	static let shared = BlockListFileManager()
	
	init() {}
	
	func updateBlockLists() {
		FileDownloader.downloadBlockListVersion { (err, json) in
			if let categoryListVersion = self.intValueFromJson(json, key: BlockListFileManager.categoryBlockListVersionKey) {
				if self.isCategoryBlockListVersionChanged(categoryListVersion) {
					self.updateCategoryBlockLists()
					Preferences.updateGlobalPreferences(key: BlockListFileManager.categoryBlockListVersionKey, value: categoryListVersion)
				}
			}
			if let blockListVersion = self.intValueFromJson(json, key: BlockListFileManager.blockListVersionKey) {
				if self.isFullBlockListVersionChanged(blockListVersion) {
					self.updateFullBlockList()
					Preferences.updateGlobalPreferences(key: BlockListFileManager.blockListVersionKey, value: blockListVersion)
				}
			}
		}
	}
	
	private func isCategoryBlockListVersionChanged(_ newVersion: Int) -> Bool {
		if let oldVersion = Preferences.globalPreferences(key: BlockListFileManager.categoryBlockListVersionKey) as? Int {
			print("isCategoryBlockListVersionChanged: Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	private func intValueFromJson(_ json: Any?, key: String) -> Int? {
		if let jsonData = json as? [String: Any] {
			return jsonData[BlockListFileManager.blockListVersionKey] as? Int
		}
		return nil
	}
	
	private func isFullBlockListVersionChanged(_ newVersion: Int) -> Bool {
		if let oldVersion = Preferences.globalPreferences(key: BlockListFileManager.blockListVersionKey) as? Int {
			print("isFullBlockListVersionChanged: Old version \(oldVersion) New version \(newVersion)")
			return newVersion != oldVersion
		}
		return true
	}
	
	func updateFullBlockList() {
		let fullBlockListName = "safariContentBlocker"
		self.downloadAndSaveFile(fullBlockListName, BlockListFileManager.assetsFolder)
	}
	
	func updateCategoryBlockLists() {
		for type in CategoryType.allCases() {
			self.downloadAndSaveFile(type.fileName(), BlockListFileManager.categoryAssetsFolder)
		}
	}
	
	
	/// Download content blocker json file and save to Group Container directory
	/// - Parameter fileName: The name of the json file
	/// - Parameter folder: The folder location in Group Containers
	private func downloadAndSaveFile(_ fileName: String, _ folder: URL?) {
		FileDownloader.downloadBlockList(fileName) { (err, data) in
			if let e = err {
				print("BlockListFileManager.downloadAndSaveFile: \(fileName) file download failed: \(e)")
			}
			if let d = data {
				print("BlockListFileManager.downloadAndSaveFile: \(fileName)")
				FileManager.default.writeFile(d, name: "\(fileName).json", in: folder)
			}
		}
	}
	
	/// Fetch the path of the Content Blocker file from the Group Container folder
	/// - Parameter fileName: The name of the content blocker json file
	/// - Parameter folderName: The name of the assests folder in Group Containers
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
}

public enum FileDownloaderError: Error {
	case invalidFileUrl
}

final class FileDownloader {
	
	class func downloadBlockListVersion(completion: @escaping (Error?, Any?) -> Void) {
		guard let url = URL(string: FileDownloader.getVersionPath()) else {
			completion(FileDownloaderError.invalidFileUrl, nil)
			return
		}
		Alamofire.request(url)
			.validate()
			.responseJSON { (response) in
				guard response.result.isSuccess else {
					print("FileDownloader.downloadBlockListVersion error: \(String(describing: response.result.error))")
					completion(response.result.error, nil)
					return
				}
				print("FileDownloader.downloadBlockListVersion: Successfully downloaded version file.")
				completion(nil, response.result.value)
		}
	}
	
	class func downloadBlockList(_ fileName: String, completion: @escaping (Error?, Data?) -> Void) {
		let urlString = "\(FileDownloader.getBasePath())/\(fileName)"
		guard let url = URL(string: urlString ) else {
			completion(FileDownloaderError.invalidFileUrl, nil)
			return
		}
		
		Alamofire.request(url)
			.validate()
			.response { response in
				if let err = response.error {
					print("FileDownloader.downloadBlockList: \(fileName) download failed: \(err)")
					completion(err, nil)
					return
				}
				print("FileDownloader.downloadBlockList: Successfully downloaded \(fileName)")
				completion(nil, response.data)
		}
	}
	
	class func getBasePath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/safari"
		#else
		return "https://staging-cdn.ghostery.com/update/safari"
		#endif
	}
	
	class func getVersionPath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/version"
		#else
		return "https://staging-cdn.ghostery.com/update/version"
		#endif
	}
}
