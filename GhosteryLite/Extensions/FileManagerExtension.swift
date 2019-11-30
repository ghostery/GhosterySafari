//
// FileManagerExtension
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

extension FileManager {
	func readJsonFile<T>(at fileUrl: URL?) -> T? {
		guard fileExists(atPath: (fileUrl?.path)!) else {
			Utils.shared.logger("\(String(describing: fileUrl?.path)) does not exist")
			return nil
		}
		do {
			let fileData = try Data(contentsOf: fileUrl!)
			return try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? T
		} catch let error as NSError {
			Utils.shared.logger("\(error), \(error.userInfo)")
			return nil
		}
	}
	
	func writeJsonFile<T>(at fileUrl: URL?, with data: T?) {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: data ?? [])
			if FileManager.default.createFile(atPath: (fileUrl?.path)!, contents: jsonData, attributes: [FileAttributeKey.posixPermissions: 0o777]) {
			} else {
				Utils.shared.logger("Could not create file")
			}
		} catch let error as NSError {
			Utils.shared.logger("\(error), \(error.userInfo)")
		}
	}
	
	func writeFile(_ data: Data, name fileName: String, in directory: URL?) {
		FileManager.default.createDirectoryIfNotExists(directory, withIntermediateDirectories: true)
		
		let fileURL = directory?.appendingPathComponent("\(fileName)")
		if FileManager.default.createFile(atPath: (fileURL?.path)!, contents: data, attributes: nil) {
			// Utils.shared.logger("\(fileName) written successfully")
		} else {
			Utils.shared.logger("Unable to write the data to \(fileName)")
		}
	}
	
	func createDirectoryIfNotExists(_ url: URL?, withIntermediateDirectories hasIntermediateDir: Bool) {
		if !FileManager.default.fileExists(atPath: (url?.path)!) {
			do {
				try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: hasIntermediateDir, attributes: nil)
			} catch let error as NSError {
				Utils.shared.logger("\(error), \(error.userInfo)")
			}
		}
	}
	
	func copyFiles(_ sourceDir: String, _ destDir: String) {
		do {
			try FileManager.default.copyItem(atPath: sourceDir, toPath: destDir)
		} catch let error as NSError {
			Utils.shared.logger("\(error), \(error.userInfo)")
		}
	}
}
