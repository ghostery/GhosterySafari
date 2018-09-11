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
}

final class BlockListFileManager {

	private static let groupIdentifier = "2UYYSSHVUH.Gh.GhosteryLite"

	private static let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: BlockListFileManager.groupIdentifier)
	private static let assetsFolder: URL? = BlockListFileManager.groupStorageFolder?.appendingPathComponent("BlockListAssets")
	private static let categoryAssetsFolder: URL? = BlockListFileManager.assetsFolder?.appendingPathComponent("BlockListByCategory")

	private static let ghosteryBlockListFileName = "ghostery_content_blocker"

	static let shared = BlockListFileManager()

	init() {
		if self.versionExpired() {
			self.downloadNewBlockList()
		}
	}

	func getFilePath(fileName: String, folderName: String) -> URL? {
		return Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: folderName)
	}

	func generateCurrentBlockList(files: [String], folderName: String, completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {
			
			var finalJSON = [[String: Any]]()
			for f in files {
				if let url = self.getFilePath(fileName: f, folderName: folderName) {
					let nextChunk: [[String:Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						finalJSON.append(contentsOf: n)
					}
				}
			}
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
//		return BlockListFileManager.categoryAssetsFolder?.appendingPathComponent(category.fileName())
//		return BlockListFileManager.categoryAssetsFolder?.appendingPathComponent("blockerList.json")

		return Bundle.main.url(forResource: "blockerList", withExtension: "json")
//		return Bundle.main.url(forResource: BlockListFileManager.ghosteryBlockListFileName, withExtension: "json")
	}

	private func versionExpired() -> Bool {
		return true
	}

	private func downloadNewBlockList() {
		FileDownloader.download("hello") { (error, data) in
			if let error = error {
				// TODO: error handling
			} else {
				let blockListFilesFolder = BlockListFileManager.assetsFolder
				FileManager.default.createDirectoryIfNotExists(blockListFilesFolder, withIntermediateDirectories: true)
				let fileURL = blockListFilesFolder?.appendingPathComponent("filename.json")
				if FileManager.default.createFile(atPath: (fileURL?.path)!, contents: data, attributes: nil) {
				} else {
					print("FileUpdate failed")
				}
			}
		}
	}
}

public enum FileDownloaderError: Error {
	case invalidAPIUrl
}

final class FileDownloader {

	class func download(_ filePath: String, completion: @escaping (Error?, Data?) -> Void) {
		let urlString = getBasePath()
		guard let url = URL(string: "\(urlString)\(filePath)") else {
			completion(FileDownloaderError.invalidAPIUrl, nil)
			return
		}
		Alamofire.request(url)
			.validate()
			.responseJSON { (response) in
				guard response.result.isSuccess else {
					completion(response.result.error, nil)
					return
				}
				completion(nil, response.data)
		}
	}

	class func getBasePath() -> String {
		#if PROD
			return "http://cdn.ghostery.com/update/"
		#else
			return "http://staging-cdn.ghostery.com/update"
		#endif
	}
}
