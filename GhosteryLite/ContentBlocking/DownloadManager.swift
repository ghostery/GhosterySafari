//
// DownloadManager
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

final class DownloadManager {
	
	static let shared = DownloadManager()
	
	/// Custom error for DownloadManager
	public enum DownloadManagerError: Error {
		case apiError
		case decodeError
		case invalidEndpoint
		case invalidResponse
	}

	/// GET specified file and return decoded JSON
	/// - Parameters:
	///   - url: The URL endpoint
	///   - completion: Callback handler of Result type
	func getJSON<T: Decodable>(url: String, completion: @escaping (Result<T, DownloadManagerError>) -> Void) {
		guard let url = URL(string: url) else {
			completion(.failure(.invalidEndpoint))
			return
		}
		URLSession.shared.dataTask(with: url) { (result) in
			switch result {
				case .success(let (response, data)):
					guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
						completion(.failure(.invalidResponse))
						return
					}
					do {
						let values = try JSONDecoder().decode(T.self, from: data)
						print("DownloadManager.getJSON: Successfully decoded JSON file.")
						completion(.success(values))
					} catch {
						completion(.failure(.decodeError))
					}
				case .failure(let error):
					print("DownloadManager.getJSON error: \(error.localizedDescription)")
					completion(.failure(.apiError))
			}
		}.resume()
	}
	
	
	/// GET specified file and return raw JSON data
	/// - Parameters:
	///   - url: The url endpoint
	///   - completion: Callback handler of Result type
	func getJSONData(url: String, completion: @escaping (Result<Data, DownloadManagerError>) -> Void) {
		guard let url = URL(string: url) else {
			completion(.failure(.invalidEndpoint))
			return
		}
		URLSession.shared.dataTask(with: url) { (result) in
			switch result {
				case .success(let (response, data)):
					guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
						completion(.failure(.invalidResponse))
						return
					}
					print("DownloadManager.getJSONData: Successfully downloaded JSON data.")
					completion(.success(data))
				case .failure(let error):
					print("DownloadManager.getJSONData error: \(error.localizedDescription)")
					completion(.failure(.apiError))
			}
		}.resume()
	}
}
