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
import Alamofire

class TelemetryService {
	
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
		let ghostrank: Int?
	}
	
	static let shared = TelemetryService()
	
	#if PROD
	private static let telemetryAPIURL = "https://d.ghostery.com"
	#else
	private static let telemetryAPIURL = "https://staging-d.ghostery.com"
	#endif
	
	func sendSignal(_ type: SignalType, config: Config, params: Params) {
		let url = self.generateSignalURL(type, config: config, params: params)
		Alamofire.request(url)
			.validate()
			.response(completionHandler: { (response) in
				if let d = response.data,
					let str = String(data: d, encoding: .utf8) {
					print("\(str)")
				}
			})
	}
	
	private func generateSignalURL(_ type: SignalType, config: Config, params: Params) -> String {
		let gr = params.ghostrank != nil ? params.ghostrank! : -1
		let url = TelemetryService.telemetryAPIURL + "/\(type.rawValue)/\(params.frequency)?gr=\(gr)" +
			"&v=\(config.version)" +
			"&os=\(config.os)" +
			"&ir=\(config.installRand)" +
			"&id=\(config.installDate)" +
			"&ua=\(config.userAgent)" +
		"&rc=\(params.recency)"
		return url
	}
}
