//
// GlobalConfigDataSource
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

class GlobalConfigManager {
	
	static let shared = GlobalConfigManager()
	
	func getCurrentConfig() -> GlobalConfigObject? {
		return GlobalConfigRepository.shared.globalConfig()
	}
	
	func switchToConfig(_ type: ConfigurationType) {
		if let _ = self.getCurrentConfig() {
			GlobalConfigRepository.shared.updateConfigType(type)
		} else {
			let _ = GlobalConfigRepository.shared.save(GlobalConfigObject(type: type))
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
