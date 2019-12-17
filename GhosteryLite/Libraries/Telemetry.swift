//
// Telemetry
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

class Telemetry {
	
	static let shared = Telemetry()
	private let config: TelemetryService.Config
	
	/// Manage ping frequency intervals
	enum Frequency: String {
		case daily = "daily"
		case weekly = "weekly"
		case monthly = "monthly"
		
		private static let day: TimeInterval = 86400
		private static let week: TimeInterval = 604800
		private static let month: TimeInterval = 2592000
		
		func isExpired(_ date: Date) -> Bool {
			switch self {
				case .daily:
					return date.timeIntervalSinceNow < -Frequency.day
				case .weekly:
					return date.timeIntervalSinceNow < -Frequency.week
				case .monthly:
					return date.timeIntervalSinceNow < -Frequency.month
			}
		}
	}

	init() {
		var id = Preferences.getGlobalPreference(key: Constants.installDateKey) as? String
		if id == nil {
			id = Telemetry.formatDate(date: Date())
		}
		self.config = TelemetryService.Config(version: Preferences.currentVersion(), installRand: Telemetry.getInstallRand(), installDate: id!)
	}
	
	/// Send a telemetry signal
	/// - Parameters:
	///   - type: The type of signal to send
	///   - source: Source of the signal (application or extension)
	func sendSignal(_ type: TelemetryService.SignalType, source: TelemetryService.PingSource? = nil) {
		switch type {
			case .install:
				TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, source: source))
				self.updateInstallParams()
			case .upgrade:
				TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, source: source))
				Preferences.setGlobalPreference(key: Constants.lastVersionKey, value: self.config.version)
				Preferences.setGlobalPreference(key: Constants.buildVersionKey, value: Preferences.currentBuildNumber())
			case .active, .engaged:
				if let src = source {
					// Check if the ping type frequency has expired
					for f in self.getFrequencies(type, source: src) {
						TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: f, source: source))
						Preferences.setGlobalPreference(key: "\(type.rawValue)_\(src.getID())_\(f.rawValue)", value: Date())
					}
				}
			default:
				return
		}
	}
	
	/// Build the signal query string
	/// - Parameters:
	///   - type: Signal type
	///   - frequency: Frequency value
	///   - source: Source of the signal (application or extension)
	private func generateParams(_ type: TelemetryService.SignalType, frequency: Frequency?, source: TelemetryService.PingSource?) -> TelemetryService.Params {
		var rec = -1
		let src = source?.getID() ?? -1
		let freq = frequency?.rawValue ?? "all"
		if let f = frequency,
			type == .active && f == .daily,
			let d = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(src)_\(f.rawValue)") as? Date {
			rec = -Int(d.timeIntervalSinceNow / 86400)
		}
		return TelemetryService.Params(recency: rec, frequency: freq, source: source)
	}
	
	/// Check for new install
	
	
	/// Get signal frequencies (daily, weekly, monthly) for the specified signal type. Returns frequencies that have expired or are not present
	/// - Parameters:
	///   - type: The signal type
	///   - source: Source of the signal (application or extension)
	private func getFrequencies(_ type: TelemetryService.SignalType, source: TelemetryService.PingSource) -> [Frequency] {
		let allFrequencies: [Frequency] = [.daily, .weekly, .monthly]
		var result = [Frequency]()
		for i in allFrequencies {
			let p = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(source.getID())_\(i.rawValue)") as? Date
			if p == nil || i.isExpired(p!) {
				result.append(i)
			}
		}
		return result
	}
	
	/// Set install pref values on new install
	private func updateInstallParams() {
		Preferences.setGlobalPreference(key: Constants.installDateKey, value: self.config.installDate)
		Preferences.setGlobalPreference(key: Constants.installRandKey, value: self.config.installRand)
		Preferences.setGlobalPreference(key: Constants.lastVersionKey, value: self.config.version)
	}
	
	/// Generate a random installation number
	private class func getInstallRand() -> Int {
		if let p = Preferences.getGlobalPreference(key: Constants.installRandKey) as? Int {
			return p
		}
		let p = Int(arc4random_uniform(100) + 1)
		Preferences.setGlobalPreference(key: Constants.installRandKey, value: p)
		return p
	}
	
	/// Date formatting utility
	/// - Parameter date: The date to format
	private class func formatDate(date: Date) -> String {
		let dt = DateFormatter()
		dt.dateFormat = "yyyy-MM-dd"
		return dt.string(from: date)
	}
}
