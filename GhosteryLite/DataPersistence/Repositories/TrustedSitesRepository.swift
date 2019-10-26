//
// TrustedSitesRepository
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
	
	public func findTrustedSite(_ name: String) -> TrustedSiteObject? {
		let realm = try! Realm()
		
		return realm.object(ofType: TrustedSiteObject.self, forPrimaryKey: name)
	}
	
}
