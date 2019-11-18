//
// URLSessionExtension
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

extension URLSession {
	
	/// Extend URLSession to use Result type in completion handler. Also takes care of redundant
	/// error handling boilerplate
	/// - Parameters:
	///   - url: The request URL
	///   - result: The callback handler
	func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
		return dataTask(with: url) { (data, response, error) in
			if let error = error {
				// Handle errors
				result(.failure(error))
				return
			}
			
			guard let response = response, let data = data else {
				// Handle empty response or empty data
				let error = NSError(domain: "error", code: 0, userInfo: nil)
				result(.failure(error))
				return
			}
			
			result(.success((response, data)))
		}
	}
}
