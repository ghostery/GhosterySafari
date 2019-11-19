//
// DomainConfigDataSource
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

class DomainConfigDataSource {
	
	func blockedCategories(forDomain name: String) -> [Categories] {
		var result = [Categories]()
		if let config = DomainConfigRepository.shared.getDomainConfig(domainName: name) {
			for i in config.blockedCategories {
				if let c = CategoryType(rawValue: i) {
					result.append(c)
				}
			}
		}
		return result
	}
	
	func updateCategoriesConfig(forDomain name: String, category: Categories, block: Bool) {
		if let config = DomainConfigRepository.shared.getDomainConfig(domainName: name) {
			config.switchCategory(type: category, isOn: block)
		}
	}
}
