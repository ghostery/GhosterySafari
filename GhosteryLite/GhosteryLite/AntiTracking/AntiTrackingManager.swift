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
	private var currentDomain: String?
	private var currentDomainConfig: DomainConfigObject?

	func domainChanged(_ newDomain: String?) {
		self.currentDomain = newDomain
		SFContentBlockerManager.reloadContentBlocker(withIdentifier: Constants.SafariContentBlockerID, completionHandler: { (error) in
				print("\(error)")
			})

	}

	func contentBlokerRules() -> [NSItemProvider] {
		var resultRules = [NSItemProvider]()
		if let domain = self.currentDomain,
			let config = DomainConfigRepository.shared.getDomainConfig(domainName: domain) {
			let blockedCategories = config.blockedCategories
			for i in blockedCategories {
				if let c = CategoryType(rawValue: i),
					let rulesURL = BlockListFileManager.shared.blockListURL(c),
					let ip = NSItemProvider(contentsOf: rulesURL) {
						resultRules.append(ip)
				}
			}
		}
		return resultRules
	}
}
