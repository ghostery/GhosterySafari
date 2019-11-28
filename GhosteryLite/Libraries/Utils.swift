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
	
	func logger<T>(_ object: T, filename: String = #file, line: Int = #line, method: String = #function) {
		#if DEBUG
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let file = URL(string: filename)?.lastPathComponent ?? ""
			Swift.print("\(dateFormatter.string(from: Foundation.Date())) >> \(file):\(line) \(method) : \(object)")
		#endif
	}
}
