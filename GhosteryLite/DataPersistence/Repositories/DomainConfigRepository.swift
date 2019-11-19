//
// DomainConfigRepository
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
	
	func switchCategory(type: Categories, isOn: Bool) {
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
