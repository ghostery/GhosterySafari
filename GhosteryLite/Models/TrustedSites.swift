//
// TrustedSites: CoreDataClass
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
import CoreData

@objc(TrustedSites)
public class TrustedSites: NSManagedObject {
	
}

/// CoreDataProperties
extension TrustedSites {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrustedSites> {
		return NSFetchRequest<TrustedSites>(entityName: "TrustedSites")
	}
	
	@NSManaged public var domain: String?
	
}
