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

/// Handles the sending of Telemetry signals
class TelemetryService {

	static let shared = TelemetryService()
	
	/// Telemetry signal types
	enum SignalType: String {
		case install = "install"
		case upgrade = "upgrade"
		case uninstall = "uninstall"
		case active = "active"
		case engaged = "engaged"
	}
	
	/// Telemetry value configuration
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
	
	/// Telemetry parameters
	struct Params {
		let recency: Int
		let frequency: String
		let source: PingSource?
	}
	
	/// Ping source origin. Used to determine where the telemetry originated
	enum PingSource: String {
		case safariExtension
		case ghosteryLiteApplication
		
		/// Returns the telemetry source ID value
		func getID() -> Int {
			switch self {
				case .safariExtension:
					return 2
				case .ghosteryLiteApplication:
					return 3
			}
		}
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
					Utils.logger("Sent ping \(type)")
				case .failure(let error):
					Utils.logger("Error: \(error)")
			}
		}
	}
	
	/// Build telemetry query string
	/// - Parameters:
	///   - type: Message type
	///   - config: Message config
	///   - params: Message parameters
	private func generateSignalURL(_ type: SignalType, config: Config, params: Params) -> String {
		let url = Constants.telemetryAPIURL + "/\(type.rawValue)/\(params.frequency)?gr=\(params.source?.getID() ?? -1)" +
			"&v=\(config.version)" +
			"&os=\(config.os)" +
			"&ir=\(config.installRand)" +
			"&id=\(config.installDate)" +
			"&ua=\(config.userAgent)" +
		"&rc=\(params.recency)"
		Utils.logger("Ping url: \(url)")
		return url
	}
}
