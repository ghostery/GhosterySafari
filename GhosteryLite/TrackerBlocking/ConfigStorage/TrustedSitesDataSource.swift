//
//  TrustedSitesDataSource.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
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
