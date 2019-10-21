//
//  FileManagerExtension.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

extension FileManager {

	func readJsonFile<T>(at fileUrl: URL?) -> T? {
		guard fileExists(atPath: (fileUrl?.path)!) else {
			print("FileManager.readJsonFile: \(String(describing: fileUrl?.path)) does not exist")
			return nil
		}
		do {
			let fileData = try Data(contentsOf: fileUrl!)
			return try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? T
		} catch {
			print("FileManager.readJsonFile error")
			return nil
		}
	}
	
	func writeJsonFile<T>(at fileUrl: URL?, with data: T?) {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: data ?? [], options: JSONSerialization.WritingOptions.prettyPrinted)
			if FileManager.default.createFile(atPath: (fileUrl?.path)!, contents: jsonData, attributes: [FileAttributeKey.posixPermissions: 0o777]) {
			} else {
				print("FileManager.writeJsonFile error")
			}
		} catch {
			print("FileManager.writeJsonFile error")
		}
	}

	func writeFile(_ data: Data, name fileName: String, in directory: URL?) {
		FileManager.default.createDirectoryIfNotExists(directory, withIntermediateDirectories: true)
		
		let fileURL = directory?.appendingPathComponent("\(fileName)")
		if FileManager.default.createFile(atPath: (fileURL?.path)!, contents: data, attributes: nil) {
			print("FileManager.writeFile: \(fileName) written successfully")
		} else {
			print("FileManager.writeFile: Unable to write the data to \(fileName)")
		}
	}

	public func createDirectoryIfNotExists(_ url: URL?, withIntermediateDirectories hasIntermediateDir: Bool) {
		if !FileManager.default.fileExists(atPath: (url?.path)!) {
			do {
				try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: hasIntermediateDir, attributes: nil)
			} catch {
				print("FileManager.createDirectoryIfNotExists error")
			}
		}
	}
}
