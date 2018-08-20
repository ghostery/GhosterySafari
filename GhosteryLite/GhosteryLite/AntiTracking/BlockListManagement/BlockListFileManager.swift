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
			return "cat_advertising.json"
		case .audioVideoPlayer:
			return "cat_audio_video_player.json"
		case .comments:
			return "cat_comments.json"
		case .customerInteraction:
			return "cat_customer_interaction.json"
		case .essential:
			return "cat_essential.json"
		case .pornvertising:
			return "cat_pornvertising.json"
		case .siteAnalytics:
			return "cat_site_analytics.json"
		case .socialMedia:
			return "cat_social_media.json"
		case .uncategorized:
			return "cat_unclassifed.json"
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

	func blockListURL(_ category: CategoryType) -> URL? {
		return BlockListFileManager.categoryAssetsFolder?.appendingPathComponent(category.fileName())
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
