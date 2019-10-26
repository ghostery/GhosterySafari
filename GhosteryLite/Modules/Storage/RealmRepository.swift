//
// RealmRepository
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

class RealmRepository<T, ID> : CrudRepository {
	
	typealias T = Object
	typealias ID = Int
	
	func save(_ obj: Object) -> Object {
		let realm = try! Realm()
		try! realm.write {
			realm.add(obj, update: .modified)
		}
		
		return obj
	}
	
	func save(_ objs: [Object]) {
		let realm = try! Realm()
		try! realm.write {
			realm.add(objs, update: .modified)
		}
	}
	
	func findOne(id: Int) -> Object? {
		let realm = try! Realm()
		
		return realm.object(ofType: Object.self, forPrimaryKey: id as Int)
	}
	
	func findAll<T>() -> [T] where T : Object {
		let realm = try! Realm()
		
		return Array(realm.objects(T.self))
	}
	
	func delete(_ obj: Object) {
		let realm = try! Realm()
		
		try! realm.write {
			realm.delete(obj)
		}
	}
	
	func deleteAll() {
		let realm = try! Realm()
		
		try! realm.write {
			realm.deleteAll()
		}
	}
	
	func deleteAllObjects(type: Object.Type) {
		let realm = try! Realm()
		let allObjs = realm.objects(type)
		try! realm.write {
			realm.delete(allObjs)
		}
	}
	
	func allObjects(type: Object.Type) -> [Object] {
		let realm = try! Realm()
		return Array(realm.objects(type))
	}
}
