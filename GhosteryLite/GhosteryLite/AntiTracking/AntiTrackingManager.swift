//
//  AntiTrackingManager.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/9/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import SafariServices

class AntiTrackingManager {

	static let shared = AntiTrackingManager()
	
	private var paused: Bool = false

	func isPaused() -> Bool {
		return self.paused
	}

	func isDefaultConfigEnabled() -> Bool {
		if let c = GlobalConfigManager.shared.getCurrentConfig() {
			return c.configType.value == ConfigurationType.byDefault.rawValue
		}
		return true
	}

	func pause() {
		self.paused = true
		reloadContentBlocker()
	}

	func resume() {
		self.paused = false
		reloadContentBlocker()
	}

	func switchToDefault() {
		GlobalConfigManager.shared.switchToConfig(.byDefault)
	}

	func switchToCustom() {
		GlobalConfigManager.shared.switchToConfig(.custom)
	}

	func reloadContentBlocker() {
		if self.isPaused() {
			loadDummyCB()
		} else {
			if let c = GlobalConfigManager.shared.getCurrentConfig(),
				c.configType.value == ConfigurationType.custom.rawValue {
				self.loadCustomCB()
			} else {
				self.loadDefaultCB()
			}
		}
	}

	func trustDomain(domain: String) {
		
	}

	func getFilePath(fileName: String) -> URL? {
		return Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "BlockListAssets/BlockListByCategory")
	}

	private func loadCustomCB() {
		if let config = GlobalConfigManager.shared.getCurrentConfig() {
			var fileNames = [String]()
			for i in config.blockedCategories {
				if let c = CategoryType(rawValue: i) {
					fileNames.append(c.fileName())
				}
			}
			self.updateAndReloadBlockList(fileNames: fileNames)
		}
	}

	private func loadDefaultCB() {
		if let config = GlobalConfigManager.shared.getCurrentConfig() {
			var fileNames = [String]()
			for i in config.defaultBlockedCategories() {
				fileNames.append(i.fileName())
			}
			self.updateAndReloadBlockList(fileNames: fileNames)
		}
	}

	private func loadDummyCB() {
		
	}

	private func updateAndReloadBlockList(fileNames: [String]) {
		BlockListFileManager.shared.generateCurrentBlockList(files: fileNames) {
			self.reloadCBExtension()
		}
	}

	private func reloadCBExtension() {
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: "Gh.GhosteryLite.ContentBlocker", completionHandler: { (error) in
			if error != nil {
				print("Reloading Content Blocker is failed ---- \(error)")
			} else {
				print("Success!")
			}
		})
	}

	func contentBlokerRules() -> [NSItemProvider] {
		var resultRules = [NSItemProvider]()
		if let config =  GlobalConfigManager.shared.getCurrentConfig() {
			let blockedCategories = config.blockedCategories
			for i in blockedCategories {
				if let c = CategoryType(rawValue: i),
					let rulesURL = BlockListFileManager.shared.blockListURL(c),
					let ip = NSItemProvider(contentsOf: rulesURL) {
						return [ip]
//						resultRules.append(ip)
				}
			}
		}
		return resultRules
	}
}
