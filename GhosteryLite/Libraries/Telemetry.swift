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
	
	private static let installDateKey = "installDate"
	private static let installRandKey = "installRand"
	private static let lastVersionKey = "lastVersion"
	private static let buildVersionKey = "lastBuildVersion"
	
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
		var id = Preferences.getGlobalPreference(key: Telemetry.installDateKey) as? String
		if id == nil {
			id = Telemetry.formatDate(date: Date())
		}
		self.config = TelemetryService.Config(version: Preferences.currentVersion(), installRand: Telemetry.getInstallRand(), installDate: id!)
	}
	
	/// Send a telemetry signal
	/// - Parameters:
	///   - type: The type of signal to send
	///   - source: Source of the signal (application or extension)
	func sendSignal(_ type: TelemetryService.SignalType, source: Int? = nil) {
		switch type {
			case .install:
				if self.isNewInstall() {
					TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, source: source))
					self.updateInstallParams()
			}
			case .upgrade:
				if self.isUpgrade() {
					TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, source: source))
				}
				Preferences.setGlobalPreference(key: Telemetry.lastVersionKey, value: self.config.version)
				Preferences.setGlobalPreference(key: Telemetry.buildVersionKey, value: Preferences.currentBuildNumber())
			case .active, .engaged:
				if let gr = source {
					for f in self.getFrequencies(type, source: gr) {
						TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: f, source: source))
						Preferences.setGlobalPreference(key: "\(type.rawValue)_\(gr)_\(f.rawValue)", value: Date())
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
	private func generateParams(_ type: TelemetryService.SignalType, frequency: Frequency?, source: Int?) -> TelemetryService.Params {
		var r = -1
		let freq = frequency?.rawValue ?? "all"
		if let f = frequency,
			type == .active && f == .daily,
			let d = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(source!)_\(f.rawValue)") as? Date {
			r = -Int(d.timeIntervalSinceNow / 86400)
		}
		return TelemetryService.Params(recency: r, frequency: freq, source: source)
	}
	
	/// Check for new install
	private func isNewInstall() -> Bool {
		return Preferences.getGlobalPreference(key: Telemetry.installDateKey) == nil
	}
	
	/// Check for upgrade
	private func isUpgrade() -> Bool {
		let lastVersion = Preferences.getGlobalPreference(key: Telemetry.lastVersionKey) as? String
		if lastVersion == nil || Preferences.currentVersion() == lastVersion! {
			let lastBuildNumber = Preferences.getGlobalPreference(key: Telemetry.buildVersionKey) as? String
			return lastBuildNumber != nil && Preferences.currentBuildNumber() != lastBuildNumber!
		}
		return true
	}
	
	/// Get signal frequency
	/// - Parameters:
	///   - type: The signal type
	///   - source: Source of the signal (application or extension)
	private func getFrequencies(_ type: TelemetryService.SignalType, source: Int) -> [Frequency] {
		let allFrequencies: [Frequency] = [.daily, .weekly, .monthly]
		var result = [Frequency]()
		for i in allFrequencies {
			let p = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(source)_\(i.rawValue)") as? Date
			if p == nil || i.isExpired(p!) {
				result.append(i)
			}
		}
		return result
	}
	
	/// Set install pref values on new install
	private func updateInstallParams() {
		Preferences.setGlobalPreference(key: Telemetry.installDateKey, value: self.config.installDate)
		Preferences.setGlobalPreference(key: Telemetry.installRandKey, value: self.config.installRand)
		Preferences.setGlobalPreference(key: Telemetry.lastVersionKey, value: self.config.version)
	}
	
	/// Generate a random installation number
	private class func getInstallRand() -> Int {
		if let p = Preferences.getGlobalPreference(key: Telemetry.installRandKey) as? Int {
			return p
		}
		let p = Int(arc4random_uniform(100) + 1)
		Preferences.setGlobalPreference(key: Telemetry.installRandKey, value: p)
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
