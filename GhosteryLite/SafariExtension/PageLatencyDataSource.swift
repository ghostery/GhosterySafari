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

	func latencyImageName(_ url: String) -> String {
		let pl = self.latencyFor(url)
		if let ld = Double(pl) {
			if ld <= 5.0 {
				return "greenLatency"
			}
			if ld <= 10 {
				return "yellowLatency"
			}
			return "redLatency"
		}
		return "noLatency"
	}
}
