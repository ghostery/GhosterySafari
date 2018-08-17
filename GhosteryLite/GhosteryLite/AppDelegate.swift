//
//  AppDelegate.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
		/*
		// Insert code here to initialize your application
		var config = Realm.Configuration(
			schemaVersion: 1,
			migrationBlock: { migration, oldSchemaVersion in
				// We haven’t migrated anything yet, so oldSchemaVersion == 0
				if (oldSchemaVersion < 1) {
					// Nothing to do!
					// Realm will automatically detect new properties and removed properties
					// And will update the schema on disk automatically
				}
		})
		// Use the default directory, but replace the filename with the username
		config.fileURL = config.fileURL!.deletingLastPathComponent()
			.appendingPathComponent("GhosteryLite.realm")
		
		// Set this as the configuration used for the default Realm
		Realm.Configuration.defaultConfiguration = config
*/
		let _ = try! Realm()

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

