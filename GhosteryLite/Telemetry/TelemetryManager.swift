//
// TelemetryManager
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

let installDateKey = "installDate"
let lastVersionKey = "lastVersion"
let installRandKey = "installRand"
let buildVersionKey = "lastBuildVersion"

class TelemetryManager {
	
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
	
	static let shared = TelemetryManager()
	
	private let config: TelemetryService.Config
	
	init() {
		var id = Preferences.getGlobalPreference(key: installDateKey) as? String
		if id == nil {
			id = TelemetryManager.formatDate(date: Date())
		}
		self.config = TelemetryService.Config(version: Preferences.currentVersion(), installRand: TelemetryManager.getInstallRand(), installDate: id!)
	}
	
	func sendSignal(_ type: TelemetryService.SignalType, ghostrank: Int? = nil) {
		switch type {
			case .install:
				if self.isNewInstall() {
					TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, ghostrank: ghostrank))
					self.updateInstallParams()
			}
			case .upgrade:
				if self.isNewVersion() {
					TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil, ghostrank: ghostrank))
				}
				Preferences.setGlobalPreference(key: lastVersionKey, value: self.config.version)
				Preferences.setGlobalPreference(key: buildVersionKey, value: Preferences.currentBuildNumber())
			case .active, .engage:
				if let gr = ghostrank {
					for f in self.getFrequencies(type, ghostrank: gr) {
						TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: f, ghostrank: ghostrank))
						Preferences.setGlobalPreference(key: "\(type.rawValue)_\(gr)_\(f.rawValue)", value: Date())
					}
			}
			default:
				return
		}
	}
	
	private func generateParams(_ type: TelemetryService.SignalType, frequency: Frequency?, ghostrank: Int?) -> TelemetryService.Params {
		var r = -1
		let freq = frequency?.rawValue ?? "all"
		if let f = frequency,
			type == .active && f == .daily,
			let d = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(ghostrank!)_\(f.rawValue)") as? Date {
			r = -Int(d.timeIntervalSinceNow / 86400)
		}
		return TelemetryService.Params(recency: r, frequency: freq, ghostrank: ghostrank)
	}
	
	private func isNewInstall() -> Bool {
		return Preferences.getGlobalPreference(key: installDateKey) == nil
	}
	
	private func isNewVersion() -> Bool {
		let lastVersion = Preferences.getGlobalPreference(key: lastVersionKey) as? String
		if lastVersion == nil || Preferences.currentVersion() == lastVersion! {
			let lastBuildNumber = Preferences.getGlobalPreference(key: buildVersionKey) as? String
			return lastBuildNumber != nil && Preferences.currentBuildNumber() != lastBuildNumber!
		}
		return true
	}
	
	private func getFrequencies(_ type: TelemetryService.SignalType, ghostrank: Int) -> [Frequency] {
		let allFrequencies: [Frequency] = [.daily, .weekly, .monthly]
		var result = [Frequency]()
		for i in allFrequencies {
			let p = Preferences.getGlobalPreference(key: "\(type.rawValue)_\(ghostrank)_\(i.rawValue)") as? Date
			if p == nil || i.isExpired(p!) {
				result.append(i)
			}
		}
		return result
	}
	
	private func updateInstallParams() {
		Preferences.setGlobalPreference(key: installDateKey, value: self.config.installDate)
		Preferences.setGlobalPreference(key: installRandKey, value: self.config.installRand)
		Preferences.setGlobalPreference(key: lastVersionKey, value: self.config.version)
	}
	
	private static func getInstallRand() -> Int {
		if let p = Preferences.getGlobalPreference(key: installRandKey) as? Int {
			return p
		}
		let p = Int(arc4random_uniform(100) + 1)
		Preferences.setGlobalPreference(key: installRandKey, value: p)
		return p
	}
	
	private static func formatDate(date: Date) -> String {
		let dt = DateFormatter()
		dt.dateFormat = "yyyy-MM-dd"
		return dt.string(from: date)
	}
}
