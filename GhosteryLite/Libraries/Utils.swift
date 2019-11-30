//
// Utils
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

class Utils {
	
	static let shared = Utils()
	
	/// Custom debug logging function
	/// - Parameters:
	///   - object: The log message
	///   - filename: Source filename
	///   - line: Source line number
	///   - method: Source method name
	func logger<T>(_ object: T, filename: String = #file, line: Int = #line, method: String = #function) {
		#if DEBUG
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let file = URL(string: filename)?.lastPathComponent ?? "" // extract the filename from the file path
			let className = file.replacingOccurrences(of: ".swift", with: "") // remove .swift extension
			let methodName = String(method[..<method.firstIndex(of: "(")!]) // remove method signature
			Swift.print("\(dateFormatter.string(from: Foundation.Date())) >> \(className).\(methodName):\(line) >> \(object)")
		#endif
	}
	
	/// Convert a String of Int to [Int]
	/// - Parameter str: String of Ints
	func stringToIntArray(_ str: String) -> [Int] {
		return str.compactMap{$0.wholeNumberValue}
	}
	
	/// Convert an [Int] to a comma-separated String
	/// - Parameter arr: Array of Int
	func intArrayToString(_ arr: [Int]) -> String {
		return arr.map{String($0)}.joined(separator: ",")
	}
}
