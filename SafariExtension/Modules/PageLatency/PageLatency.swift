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

	func pageLoaded(url: String, latency: String) {
		pageLatencies[url] = latency
	}

	func latencyFor(_ url: String) -> String {
		return pageLatencies[url] ?? "--"
	}

	func latencyImageAndOffset(_ url: String) -> (String, CGFloat) {
		let pl = self.latencyFor(url)
		if let ld = Double(pl) {
			if ld <= 5.0 {
				return ("greenLatency", 14)
			}
			if ld < 10 {
				return ("yellowLatency", 74)
			}
			return ("redLatency", 134)
		}
		return ("noLatency", -100)
	}
}
