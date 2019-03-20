//
//  BlockListFileManager.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/8/18.
//  Copyright © 2018 Ghostery. All rights reserved.
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

	private static let ghosteryBlockListFileName = "ghostery_content_blocker"

	private static let blockListVersionKey = "safariContentBlockerVersion"
	private static let categoryBlockListVersionKey = "safariCategoryVersion"

	static let shared = BlockListFileManager()

	init() {
	}

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
			return newVersion != oldVersion
		}
		return true
	}

	func updateFullBlockList() {
		let fullBlockListName = "safariContentBlocker"
		self.downloadAndSaveFile(fullBlockListName)
	}

	func updateCategoryBlockLists() {
		for type in CategoryType.allCases() {
			self.downloadAndSaveFile(type.fileName())
		}
	}

	private func downloadAndSaveFile(_ fileName: String) {
		FileDownloader.downloadBlockList(fileName) { (err, data) in
			if let e = err {
				print("\(fileName) file download is failed: \(e)")
			}
			if let d = data {
				FileManager.default.writeFile(d, name: "\(fileName).json", in: BlockListFileManager.assetsFolder)
			}
		}
	}

	func getFilePath(fileName: String, folderName: String) -> URL? {
		return Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: folderName)
	}

	func generateCurrentBlockList(files: [String], folderName: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			
			var blockListJSON = [[String: Any]]()
			for f in files {
				if let url = self.getFilePath(fileName: f, folderName: folderName) {
					let nextChunk: [[String:Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						blockListJSON.append(contentsOf: n)
					}
				}
			}
			let r = WhiteListFileManager.shared.getActiveWhitelistRules()
			let finalJSON: [[String: Any]] = (blockListJSON ?? []) + (r ?? [])

			let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
			let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
			let categoryAssetsFolder: URL? = assetsFolder?.appendingPathComponent("BlockListByCategory")
			let currentBlockList = assetsFolder?.appendingPathComponent("currentBlockList.json")
			FileManager.default.createDirectoryIfNotExists(assetsFolder, withIntermediateDirectories: true)
			if let url = currentBlockList {
				try? FileManager.default.removeItem(at: url)
				FileManager.default.writeJsonFile(at: url, with: finalJSON)
			}
			DispatchQueue.main.async {
				completion()
			}
		}
	}

	func blockListURL(_ category: CategoryType) -> URL? {
		return Bundle.main.url(forResource: "blockerList", withExtension: "json")
	}

}

public enum FileDownloaderError: Error {
	case invalidFileUrl
}

final class FileDownloader {

	class func downloadBlockListVersion(completion: @escaping (Error?, Any?) -> Void) {
		FileDownloader.loadJSONFile(FileDownloader.getVersionPath()) { (err, data) in
			completion(err, data)
		}
	}

	private class func loadJSONFile(_ url: String, completion: @escaping (Error?, Any?) -> Void) {
		guard let url = URL(string: url) else {
			completion(FileDownloaderError.invalidFileUrl, nil)
			return
		}
		Alamofire.request(url)
			.validate()
			.responseJSON { (response) in
				guard response.result.isSuccess else {
					completion(response.result.error, nil)
					return
				}
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
					// TODO: Integrate proper logging
					print("File downloading is failed: \(err)")
					completion(err, nil)
					return
				}
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
	//safariContentBlockerVersion
	//safariCategoryVersion
}
