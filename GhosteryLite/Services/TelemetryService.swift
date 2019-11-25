//
// TelemetryService
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

class TelemetryService {

	static let shared = TelemetryService()
	
	enum SignalType: String {
		case install = "install"
		case upgrade = "upgrade"
		case uninstall = "uninstall"
		case active = "active"
		case engage = "engaged"
	}
	
	struct Config {
		let os = "mac"
		let userAgent = "gl"
		let version: String
		let installDate: String
		let installRand: Int
		
		init(version: String, installRand: Int, installDate: String) {
			self.version = version
			self.installRand = installRand
			self.installDate = installDate
		}
	}
	
	struct Params {
		let recency: Int
		let frequency: String
		let source: Int? /// Extension = 2, Application = 3
	}
	
	/// Send telemetry message
	/// - Parameters:
	///   - type: Message type
	///   - config: Message config
	///   - params: Message parameters
	func sendSignal(_ type: SignalType, config: Config, params: Params) {
		let url = self.generateSignalURL(type, config: config, params: params)
		HTTPService.shared.getJSONData(url: url) { (completion: Result<Data, HTTPService.HTTPServiceError>) in
			switch completion {
				case .success(_):
					print("TelemetryService.sendSignal: Sent ping \(type)")
				case .failure(let error):
					print("TelemetryService.sendSignal error: \(error.localizedDescription)")
			}
		}
	}
	
	/// Build telemetry query string
	/// - Parameters:
	///   - type: Message type
	///   - config: Message config
	///   - params: Message parameters
	private func generateSignalURL(_ type: SignalType, config: Config, params: Params) -> String {
		let gr = params.source != nil ? params.source! : -1
		let url = Constants.telemetryAPIURL + "/\(type.rawValue)/\(params.frequency)?gr=\(gr)" +
			"&v=\(config.version)" +
			"&os=\(config.os)" +
			"&ir=\(config.installRand)" +
			"&id=\(config.installDate)" +
			"&ua=\(config.userAgent)" +
		"&rc=\(params.recency)"
		return url
	}
}
