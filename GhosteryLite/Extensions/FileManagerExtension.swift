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
	/// Read from JSON file and return a jsonObject
	/// - Parameter fileUrl: The json file URL
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
	
	/// Writes a JSON object to disk
	/// - Parameters:
	///   - fileUrl: The URL of the json file to write
	///   - data: The json data
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
	
	/// Writes a file to disk
	/// - Parameters:
	///   - data: The file data
	///   - fileName: The filename to write
	///   - directory: The directory where the file should be written
	func writeFile(_ data: Data, name fileName: String, in directory: URL?) {
		FileManager.default.createDirectoryIfNotExists(directory, withIntermediateDirectories: true)
		
		let fileURL = directory?.appendingPathComponent("\(fileName)")
		if FileManager.default.createFile(atPath: (fileURL?.path)!, contents: data, attributes: nil) {
			// Utils.shared.logger("\(fileName) written successfully")
		} else {
			Utils.shared.logger("Unable to write the data to \(fileName)")
		}
	}
	
	/// Creates a new directory if it does not exist
	/// - Parameters:
	///   - url: A file URL that specifies the directory to create
	///   - hasIntermediateDir: If true, this method creates any nonexistent parent directories as part of creating the directory in url
	func createDirectoryIfNotExists(_ url: URL?, withIntermediateDirectories hasIntermediateDir: Bool) {
		if !FileManager.default.fileExists(atPath: (url?.path)!) {
			do {
				try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: hasIntermediateDir, attributes: nil)
			} catch let error as NSError {
				Utils.shared.logger("\(error), \(error.userInfo)")
			}
		}
	}
	
	/// Copy files from source to destination directories
	/// - Parameters:
	///   - sourceDir: The source directory
	///   - destDir: The destination directory
	func copyFiles(_ sourceDir: String, _ destDir: String) {
		do {
			try FileManager.default.copyItem(atPath: sourceDir, toPath: destDir)
		} catch let error as NSError {
			Utils.shared.logger("\(error), \(error.userInfo)")
		}
	}
}
