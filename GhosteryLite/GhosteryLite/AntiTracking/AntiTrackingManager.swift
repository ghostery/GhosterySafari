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

	func reloadContentBlocker() {
		if let config =  GlobalConfigDataSource.shared.getCurrentConfig() {
			var fileNames = [String]()
			for i in config.blockedCategories {
				if let c = CategoryType(rawValue: i) {
					fileNames.append(c.fileName())
				}
			}
			BlockListFileManager.shared.generateCurrentBlockList(files: fileNames) {
				SFContentBlockerManager.reloadContentBlocker(withIdentifier: "Gh.GhosteryLite.ContentBlocker", completionHandler: { (error) in
					if error != nil {
						print("Reloading Content Blocker is failed ---- \(error)")
					} else {
						print("Success!")
					}
				})
			}
		}
	}

	func getFilePath(fileName: String) -> URL? {
		return Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "BlockListAssets/BlockListByCategory")
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
