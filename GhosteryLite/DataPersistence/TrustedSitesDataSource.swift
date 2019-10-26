//
// TrustedSitesDataSource
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

class TrustedSitesDataSource {
	
	static let shared = TrustedSitesDataSource()
	
	func addDomain(_ domain: String) {
		let _ = TrustedSitesRepository.shared.save(TrustedSiteObject(domain))
	}
	
	func removeDomain(_ domain: String) {
		if let obj = TrustedSitesRepository.shared.findTrustedSite(domain) {
			self.removeObject(obj)
		}
	}
	
	func removeObject(_ trustedSiteObj: TrustedSiteObject) {
		TrustedSitesRepository.shared.delete(trustedSiteObj)
	}
	
	func allTrustedSites() -> [TrustedSiteObject] {
		return TrustedSitesRepository.shared.trustedSites() ?? [TrustedSiteObject]()
	}
	
	func isTrusted(_ name: String) -> Bool {
		return TrustedSitesRepository.shared.findTrustedSite(name) != nil
	}
}
