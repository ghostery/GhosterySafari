//
// CrudRepository
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
