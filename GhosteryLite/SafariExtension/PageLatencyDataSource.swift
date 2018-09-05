//
//  PageLoadingTime.swift
//  SafariExtension
//
//  Created by Sahakyan on 8/29/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class PageLatencyDataSource {

	static let shared = PageLatencyDataSource()

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
