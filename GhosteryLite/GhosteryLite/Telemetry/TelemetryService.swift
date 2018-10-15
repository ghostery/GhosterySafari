//
//  TelemetryService.swift
//  GhosteryLite
//
//  Created by Sahakyan on 9/21/18.
//  Copyright © 2018 Ghostery. All rights reserved.
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
		let url = TelemetryService.telemetryAPIURL + "/\(type.rawValue)/\(params.frequency)?gr=-1" +
			"&v=\(config.version)" +
			"&os=\(config.os)" +
			"&ir=\(config.installRand)" +
			"&id=\(config.installDate)" +
			"&ua=\(config.userAgent)" +
			"&rc=\(params.recency)"
		return url
	}
}
