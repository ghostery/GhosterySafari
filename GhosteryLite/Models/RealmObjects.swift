//
// RealmObjects
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

class TrustedSiteObject: RealmSwift.Object {
	@objc dynamic var name: String?
	
	convenience init(_ domain: String) {
		self.init()
		name = domain
	}
	
	override static func primaryKey() -> String? {
		return "name"
	}
}

class GlobalConfigObject: RealmSwift.Object {
	@objc dynamic var id = 0
	
	let configType = RealmOptional<Int>()
	let blockedCategories = List<Int>()
	
	convenience init(type: Categories) {
		self.init()
		configType.value = type.rawValue
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
