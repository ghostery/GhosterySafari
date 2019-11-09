//
// FileDownloader
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

final class FileDownloader {
	
	static let shared = FileDownloader()
	
	private enum FileDownloaderError: Error {
		case invalidFileUrl
	}
	
	func downloadBlockListVersion(completion: @escaping (Error?, Any?) -> Void) {
		guard let url = URL(string: self.getVersionPath()) else {
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
	
	func downloadBlockList(_ fileName: String, completion: @escaping (Error?, Data?) -> Void) {
		let urlString = "\(self.getBasePath())/\(fileName)"
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
	
	private func getBasePath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/safari"
		#else
		return "https://staging-cdn.ghostery.com/update/safari"
		#endif
	}
	
	 private func getVersionPath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/version"
		#else
		return "https://staging-cdn.ghostery.com/update/version"
		#endif
	}
}
