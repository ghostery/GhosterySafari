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
}

final class BlockListFileManager {
	private static let ghosteryBlockListFileName = "ghostery_content_blocker"
	
	static let shared = BlockListFileManager()

	init() {
		if self.versionExpired() {
			self.downloadNewBlockList()
		}
	}

	func blockListURL(_ category: CategoryType) -> URL? {
		return Bundle.main.url(forResource: BlockListFileManager.ghosteryBlockListFileName, withExtension: "json")
	}

	private func versionExpired() -> Bool {
		return true
	}

	private func downloadNewBlockList() {
		
	}
}

public enum FileDownloaderError: Error {
	case invalidAPIUrl
}

final class FileDownloader {

	private func download(_ fileName: String, completion: @escaping (Error?, Data?) -> Void) {
		let urlString = getURL(fileName: fileName)
		guard let url = URL(string: urlString ) else {
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

	private func getURL(fileName: String) -> String {
		return ""
	}
}
