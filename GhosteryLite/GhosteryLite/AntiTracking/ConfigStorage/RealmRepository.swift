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
	
	func save(_ obj: T) -> T {
		let realm = try! Realm()
		try! realm.write {
			realm.add(obj as Object, update: true)
		}
		
		return obj
	}
	
	func save(_ objs: [T]) {
		let realm = try! Realm()
		try! realm.write {
			realm.add(objs, update: true)
		}
	}
	
	func findOne(id: ID) -> T? {
		let realm = try! Realm()
		
		return realm.object(ofType: T.self, forPrimaryKey: id)
	}
	
	func findAll<T: Object>() -> [T] {
		let realm = try! Realm()
		
		return Array(realm.objects(T.self))
	}
	
	func delete(_ obj: T ) {
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
