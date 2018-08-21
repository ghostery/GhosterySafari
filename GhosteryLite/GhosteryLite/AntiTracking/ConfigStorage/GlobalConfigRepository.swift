//
//  GlobalConfigRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import RealmSwift

enum ConfigurationType: Int {
	case custom
	case byDefault
}

class GlobalConfigObject: RealmSwift.Object {

	let configType = RealmOptional<Int>()
	public var blockedCategories = List<Int>()

	convenience init(type: ConfigurationType) {
		self.init()
		configType.value = type.rawValue
	}

	func switchCategory(type: CategoryType, isOn: Bool) {
		if isOn && !blockedCategories.contains(type.rawValue) {
			blockedCategories.append(type.rawValue)
		}
		if !isOn && blockedCategories.contains(type.rawValue) {
			blockedCategories.remove(at: type.rawValue)
		}
	}
}

class GlobalConfigRepository: RealmRepository<GlobalConfigObject, String> {
	
	static let shared = GlobalConfigRepository()

	public func globalConfig() -> GlobalConfigObject? {
		let list = self.findAll()
		return list.count > 0 ? list[0] as? GlobalConfigObject : nil
	}
}
