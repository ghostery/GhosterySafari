//
//  GlobalConfigDataSource.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class GlobalConfigDataSource {
	
	func getCurrentConfig() -> GlobalConfigObject? {
		return GlobalConfigRepository.shared.globalConfig()
    }

	func createConfigIfDoesNotExist() {
		guard let _ = self.getCurrentConfig() else {
			return
		}
		let _ = GlobalConfigRepository.shared.save(GlobalConfigObject(type: .byDefault))
	}

	func isCategoryBlocked(_ categoryType: CategoryType) -> Bool {
		if let c = self.getCurrentConfig() {
			return c.blockedCategories.contains(categoryType.rawValue)
		}
		return false
	}
}
