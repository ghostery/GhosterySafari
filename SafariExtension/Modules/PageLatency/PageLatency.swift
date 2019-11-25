//
// PageLatency
// SafariExtension
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

class PageLatency {
	static let shared = PageLatency()
	var pageLatencies = [String: String]()
	
	/// Save latency for a page URL once page load has completed
	/// - Parameters:
	///   - url: The page URL
	///   - latency: The latency value
	func pageLoaded(url: String, latency: String) {
		pageLatencies[url] = latency
	}
	
	/// Return the latency value for a given page URL
	/// - Parameter url: The page URL
	func latencyFor(_ url: String) -> String {
		return pageLatencies[url] ?? "--"
	}
	
	/// Generate the image representation for a latency value and it's offset position in the view controller
	/// - Parameter url: The page URL
	func latencyImageAndOffset(_ url: String) -> (String, CGFloat) {
		let latency = self.latencyFor(url)
		if let latencyVal = Double(latency) {
			if latencyVal <= 5.0 {
				return ("greenLatency", 14)
			}
			if latencyVal < 10 {
				return ("yellowLatency", 74)
			}
			return ("redLatency", 134)
		}
		return ("noLatency", -100)
	}
}
