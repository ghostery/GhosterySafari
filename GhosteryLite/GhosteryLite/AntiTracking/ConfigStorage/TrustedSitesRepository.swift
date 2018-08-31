//
//  TrustedSitesRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import RealmSwift

class TrustedSiteObject: RealmSwift.Object {
	
	@objc dynamic var name: String?

	convenience init(_ domain: String) {
		self.init()
		name = domain
	}

	override static func primaryKey() -> String? {
		return "name"
	}
	
}

class TrustedSitesRepository: RealmRepository<TrustedSiteObject, String> {
	
	static let shared = TrustedSitesRepository()

	public func trustedSites() -> [TrustedSiteObject]? {
		let list: [TrustedSiteObject] = self.findAll()
		return list
	}

}
