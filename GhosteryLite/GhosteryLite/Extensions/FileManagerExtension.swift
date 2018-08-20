//
//  FileManagerExtension.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

extension FileManager {
	
	public func createDirectoryIfNotExists(_ url: URL?, withIntermediateDirectories hasIntermediateDir: Bool) {
		if !FileManager.default.fileExists(atPath: (url?.path)!) {
			do {
				try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: hasIntermediateDir, attributes: nil)
			} catch {
				print("Fail")
			}
		}
	}
}
