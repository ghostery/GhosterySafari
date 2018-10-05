//
//  URLExtension.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/7/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

extension URL {

	public var normalizedHost: String? {
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

	public var fullPath: String {
		var scheme = self.scheme ?? ""
		if !scheme.isEmpty {
			scheme.append("://")
		}
		let host = self.host ?? ""
		let path = self.path ?? ""
		return "\(scheme)\(host)\(path)"
	}

}
