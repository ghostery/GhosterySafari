//
//  RealmRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/16/18.
//  Copyright © 2018 Ghostery. All rights reserved.
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
