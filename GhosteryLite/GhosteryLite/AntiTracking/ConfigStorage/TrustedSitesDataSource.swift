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

	func trustSite(_ domain: String) {
		let obj = TrustedSitesRepository.shared.save(TrustedSiteObject(domain))
		if obj == nil {
			// Handle Error
		}
	}

	func untrustSite(_ trustedSiteObj: TrustedSiteObject) {
		TrustedSitesRepository.shared.delete(trustedSiteObj)
	}

	func allTrustedSites() -> [TrustedSiteObject] {
		return TrustedSitesRepository.shared.trustedSites() ?? [TrustedSiteObject]()
	}
}
