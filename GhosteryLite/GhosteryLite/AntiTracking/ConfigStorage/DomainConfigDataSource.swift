//
//  DomainConfigDataSource.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/17/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class DomainConfigDataSource {
	
	func blockedCategories(forDomain name: String) -> [CategoryType] {
		var result = [CategoryType]()
		if let config = DomainConfigRepository.shared.getDomainConfig(domainName: name) {
			for i in config.blockedCategories {
				if let c = CategoryType(rawValue: i) {
					result.append(c)
				}
			}
		}
		return result
	}

	func updateCategoriesConfig(forDomain name: String, category: CategoryType, block: Bool) {
		if let config = DomainConfigRepository.shared.getDomainConfig(domainName: name) {
			config.switchCategory(type: category, isOn: block)
		}
	}
}
