//
// PersistentContainer
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

/// Override the default CoreData storage location to use the App Group (Group Containers)
class PersistentContainer: NSPersistentContainer {
	/// Creates the default directory for the persistent stores on the current platform
	override class func defaultDirectoryURL() -> URL {
		guard let dbDirectory = Constants.GroupStorageFolderURL else {
			fatalError("PersistentContainer.defaultDirectoryURL: Error finding SQLite group directory.")
		}
		return dbDirectory.appendingPathComponent("GhosteryLite.sqlite")
	}
}
