//
//  CrudRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/16/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import RealmSwift

/// Protocol for generic CRUD operations

protocol CrudRepository {
	
	associatedtype T
	associatedtype ID
	
	/// Finds all instances of given type
	///
	/// - Returns: all entries
	func findAll<T: Object>() -> [T]
	
	
	/// Find entry by id
	///
	/// - Parameter id: Entry id, must not be null!
	/// - Returns: Entity for given id if found, otherwise nil
	func findOne(id: ID) -> T?
	
	
	/// Saves given entity
	///
	/// - Parameter obj: Entity
	/// - Returns: Saved Entity
	func save(_ obj: T) -> T
	
	
	/// Deletes given entity
	///
	/// - Parameter obj: The entity
	func delete(_ obj: T)
	
	
	/// Deleted all entities
	func deleteAll()
}
