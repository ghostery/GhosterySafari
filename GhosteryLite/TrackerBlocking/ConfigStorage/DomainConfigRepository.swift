//
//  DomainConfigRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/16/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import RealmSwift

class DomainConfigObject: RealmSwift.Object {

	@objc dynamic var name: String?
	public var blockedCategories = List<Int>()

	convenience init(name: String) {
		self.init()
		self.name = name
	}
	
	override class func primaryKey() -> String? {
		return "name"
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

class DomainConfigRepository: RealmRepository<DomainConfigObject, String> {

	static let shared = DomainConfigRepository()

	func getDomainConfig(domainName: String) -> DomainConfigObject? {
		let realm = try! Realm()
		let config = realm.object(ofType: DomainConfigObject.self, forPrimaryKey: domainName)
		return config
	}
}
