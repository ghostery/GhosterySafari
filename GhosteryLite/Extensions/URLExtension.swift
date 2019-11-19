//
// URLExtension
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

extension URL {
	var normalizedHost: String? {
		// Use components.host instead of self.host since the former correctly preserves
		// brackets for IPv6 hosts, whereas the latter strips them.
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), var host = components.host, host != "" else {
			return nil
		}
		
		if let range = host.range(of: "^(www|mobile|m)\\.", options: .regularExpression) {
			host.replaceSubrange(range, with: "")
		}
		
		return host
	}
	
	var fullPath: String {
		var scheme = self.scheme ?? ""
		if !scheme.isEmpty {
			scheme.append("://")
		}
		let host = self.host ?? ""
		let regEx = try? NSRegularExpression(pattern: "/+$", options: .caseInsensitive)
		let newPath = regEx?.stringByReplacingMatches(in: self.path, options: [], range: NSMakeRange(0, self.path.count), withTemplate: "") ?? ""
		return "\(scheme)\(host)\(newPath)"
	}
}
