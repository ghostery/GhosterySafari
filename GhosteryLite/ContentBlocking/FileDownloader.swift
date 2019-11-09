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
	
	/// Custom error for FileDownloader
	private enum FileDownloaderError: Error {
		case invalidFileUrl
	}

	/// Fetch the Ghostery block list version file
	/// - Parameter completion: Callback handler
	func downloadGhosteryBlockListVersion(completion: @escaping (Error?, Any?) -> Void) {
		guard let url = URL(string: self.getGhosteryVersionPath()) else {
			completion(FileDownloaderError.invalidFileUrl, nil)
			return
		}
		Alamofire.request(url)
			.validate()
			.responseJSON { (response) in
				guard response.result.isSuccess else {
					print("FileDownloader.downloadGhosteryBlockListVersion error: \(String(describing: response.result.error))")
					completion(response.result.error, nil)
					return
				}
				print("FileDownloader.downloadGhosteryBlockListVersion: Successfully downloaded version file.")
				completion(nil, response.result.value)
		}
	}
	
	/// Fetch Cliqz Safari block lists checksums
	/// - Parameter completion: Callback handler
	func downloadCliqzSafariLists(completion: @escaping (Error?, Data?) -> Void) {
		let urlString = "https://cdn.cliqz.com/adblocker/configs/safari-ads/allowed-lists.json"
		guard let url = URL(string: urlString ) else {
			completion(FileDownloaderError.invalidFileUrl, nil)
			return
		}
		
		Alamofire.request(url)
			.validate()
			.responseJSON { (response) in
				guard response.result.isSuccess else {
					print("FileDownloader.downloadCliqzSafariLists error: \(String(describing: response.result.error))")
					completion(response.result.error, nil)
					return
				}
				print("FileDownloader.downloadCliqzSafariLists: Successfully downloaded Cliqz Safari lists file.")
				completion(nil, response.data)
		}
	}
	
	/// Download block list json files from CDN
	/// - Parameters:
	///   - fileName: The name of the block list file
	///   - listType: The type of list (Cliqz or Ghostery)
	///   - completion: Callback handler
	func downloadBlockList(_ fileName: String, _ listType: String, completion: @escaping (Error?, Data?) -> Void) {
		let urlString = (listType == "ghostery") ? "\(self.getGhosteryBasePath())/\(fileName)" : fileName
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
	
	private func getGhosteryBasePath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/safari"
		#else
		return "https://staging-cdn.ghostery.com/update/safari"
		#endif
	}
	
	 private func getGhosteryVersionPath() -> String {
		#if PROD
		return "https://cdn.ghostery.com/update/version"
		#else
		return "https://staging-cdn.ghostery.com/update/version"
		#endif
	}
}
