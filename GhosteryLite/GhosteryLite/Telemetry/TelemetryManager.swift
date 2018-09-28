//
//  TelemetryManager.swift
//  GhosteryLite
//
//  Created by Sahakyan on 9/26/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

let installDateKey = "installDate"
let lastVersionKey = "lastVersion"
let installRandKey = "installRand"

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
		var id = Preferences.globalPreferences(key: installDateKey) as? String
		if id == nil {
			id = TelemetryManager.formatDate(date: Date())
		}
		self.config = TelemetryService.Config(version: Preferences.currentVersion(), installRand: TelemetryManager.getInstallRand(), installDate: id!)
	}

	func sendSignal(_ type: TelemetryService.SignalType) {
		switch type {
		case .install:
			if self.isNewInstall() {
				TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil))
				self.updateInstallParams()
			}
		case .upgrade:
			if self.isNewVersion() {
				TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: nil))
				Preferences.updateGlobalPreferences(key: lastVersionKey, value: self.config.version)
			}
		case .active, .engage:
			for f in self.getFrequencies(type) {
				TelemetryService.shared.sendSignal(type, config: self.config, params: self.generateParams(type, frequency: f))
				Preferences.updateGlobalPreferences(key: "\(type.rawValue)_\(f.rawValue)", value: Date())
			}
		default:
			return
		}
	}

	private func generateParams(_ type: TelemetryService.SignalType, frequency: Frequency?) -> TelemetryService.Params {
		var r = -1
		let freq = frequency?.rawValue ?? "all"
		if let f = frequency,
			type == .active && f == .daily,
			let d = Preferences.globalPreferences(key: "\(type.rawValue)_\(f.rawValue)")as? Date {
			r = -Int(d.timeIntervalSinceNow / 86400)
		}
		return TelemetryService.Params(recency: r, frequency: freq)
	}

	private func isNewInstall() -> Bool {
		return Preferences.globalPreferences(key: installDateKey) == nil
	}

	private func isNewVersion() -> Bool {
		let lastVersion = Preferences.globalPreferences(key: lastVersionKey) as? String
		return lastVersion != nil && Preferences.currentVersion() != lastVersion!
	}

	private func getFrequencies(_ type: TelemetryService.SignalType) -> [Frequency] {
		let allFrequencies: [Frequency] = [.daily, .weekly, .monthly]
		var result = [Frequency]()
		for i in allFrequencies {
			let p = Preferences.globalPreferences(key: "\(type.rawValue)_\(i.rawValue)") as? Date
			if p == nil || i.isExpired(p!) {
				result.append(i)
			}
		}
		return result
	}

	private func updateInstallParams() {
		Preferences.updateGlobalPreferences(key: installDateKey, value: self.config.installDate)
		Preferences.updateGlobalPreferences(key: installRandKey, value: self.config.installRand)
		Preferences.updateGlobalPreferences(key: lastVersionKey, value: self.config.version)
	}

	private static func getInstallRand() -> Int {
		if let p = Preferences.globalPreferences(key: installRandKey) as? Int {
			return p
		}
		let p = Int(arc4random_uniform(100) + 1)
		Preferences.updateGlobalPreferences(key: installRandKey, value: p)
		return p
	}

	private static func formatDate(date: Date) -> String {
		let dt = DateFormatter()
		dt.dateFormat = "yyyy-MM-dd"
		return dt.string(from: date)
	}
}
