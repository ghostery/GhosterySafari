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
	
	private var isPaused: Bool = false

	/* No need for now
	private var currentDomain: String?
	private var currentDomainConfig: DomainConfigObject?


	func domainChanged(_ newDomain: String?) {
		self.currentDomain = newDomain
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: Constants.SafariContentBlockerID, completionHandler: { (error) in
				print("\(error)")
			})

	}
	*/

	func pause() {
		self.isPaused = true
		reloadContentBlocker()
	}

	func resume() {
		self.isPaused = false
		reloadContentBlocker()
	}

	func switchToDefault() {
		
	}

	func switchToCustom() {
		
	}

	func reloadContentBlocker() {
		if self.isPaused {
			loadDummyCB()
		} else {
			if let _ =  GlobalConfigDataSource.shared.getCurrentConfig() {
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
		if let config =  GlobalConfigDataSource.shared.getCurrentConfig() {
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
		if let config =  GlobalConfigDataSource.shared.getCurrentConfig() {
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
