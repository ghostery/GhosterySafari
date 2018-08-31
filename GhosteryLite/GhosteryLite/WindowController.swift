//
//  WindowController.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/21/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import RealmSwift

class WindowController: NSWindowController {
	
	override func windowWillLoad() {
		super.windowWillLoad()
		let config = Realm.Configuration(
			// Set the new schema version. This must be greater than the previously used
			// version (if you've never set a schema version before, the version is 0).
			schemaVersion: 1,
			
			// Set the block which will be called automatically when opening a Realm with
			// a schema version lower than the one set above
			migrationBlock: { migration, oldSchemaVersion in
				// We haven’t migrated anything yet, so oldSchemaVersion == 0
				if (oldSchemaVersion < 1) {
					// Nothing to do!
					// Realm will automatically detect new properties and removed properties
					// And will update the schema on disk automatically
				}
		})
		
		// Tell Realm to use this new configuration object for the default Realm
		Realm.Configuration.defaultConfiguration = config
		let _ = try! Realm()
		GlobalConfigManager.shared.createConfigIfDoesNotExist()
	}

}
