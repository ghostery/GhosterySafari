//
// CoreDataStack
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

import Cocoa

/// Establishes an access point for CoreData persistentContainer
class CoreDataStack {
	
	static let shared = CoreDataStack()
	
	/// The persistent container for the application
	lazy var persistentContainer: NSPersistentContainer = {
		let container = PersistentContainer(name: "GhosteryLite")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("CoreDataStack.persistentContainer error: \(error), \(error.userInfo)")
			}
		})
		return container
	}()
}
