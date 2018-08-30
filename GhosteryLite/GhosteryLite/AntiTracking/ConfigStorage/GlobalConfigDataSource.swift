//
//  GlobalConfigDataSource.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class GlobalConfigDataSource {
	
	static let shared = GlobalConfigDataSource()

	func getCurrentConfig() -> GlobalConfigObject? {
		return GlobalConfigRepository.shared.globalConfig()
    }

	func switchConfigType(_ type: ConfigurationType) {
		if let _ = self.getCurrentConfig() {
			GlobalConfigRepository.shared.updateConfigType(type)
		} else if type == .custom {
			let _ = GlobalConfigRepository.shared.save(GlobalConfigObject(type: .custom))
		}
	}

	// Temp method
	func createConfigIfDoesNotExist(type: ConfigurationType = .byDefault) {
		if let _ = self.getCurrentConfig() {
			return
		}
		let _ = GlobalConfigRepository.shared.save(GlobalConfigObject(type: type))
	}

	func isCategoryBlocked(_ categoryType: CategoryType) -> Bool {
		if let c = self.getCurrentConfig() {
			return c.blockedCategories.contains(categoryType.rawValue)
		}
		return false
	}

	func changeCategoryStatus(_ categoryType: CategoryType, status: Bool) -> Bool {
		GlobalConfigRepository.shared.updateCategoryStatus(type: categoryType, isOn: status)
		return false
	}

	func isDefault() -> Bool {
		if let c = self.getCurrentConfig() {
			return c.configType.value == ConfigurationType.custom.rawValue
		}
		return true
	}
}
