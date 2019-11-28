//
// TrustedSite
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

import Cocoa
import CoreData

class TrustedSite {
	
	var domain: String?
	
	static let shared = TrustedSite()
	
	/// Is the domain in the TrustedSites entity in CoreData
	/// - Parameter domain: The domain name to check
	func isSiteTrusted(_ domain: String) -> Bool {
		return self.getTrustedSite(domain) != nil
	}
	
	/// Get all TrustedSites from CoreData as a list of domains
	func getTrustedSites() -> [String]? {
		if let sites = self.getTrustedSitesEntity() {
			var domains = [String]()
			for domain in sites as [NSManagedObject] {
				if let d = domain.value(forKey: "domain") as? String {
					domains.append(d)
				}
			}
			return domains
		}
		return nil
	}
	
	/// Fetch a Trusted Site from CoreData by domain as an NSManagedObject
	/// - Parameter domain: The domain name to find
	func getTrustedSite(_ domain: String) -> NSManagedObject? {
		if let sites = self.getTrustedSitesEntity() {
			for site in sites as [NSManagedObject] {
				if let d = site.value(forKey: "domain") as? String {
					if d == domain {
						return site
					}
				}
			}
		}
		return nil
	}
	
	/// Add a new domain to the TrustedSites entity in CoreData
	/// - Parameter domain: The domain to add
	func addDomain(_ domain: String) {
		guard let _ = self.getTrustedSite(domain) else {
			guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
				return
			}
			let managedContext = appDelegate.persistentContainer.viewContext
			let entity = NSEntityDescription.entity(forEntityName: "TrustedSites", in: managedContext)!
			let site = NSManagedObject(entity: entity, insertInto: managedContext)
			site.setValue(domain, forKeyPath: "domain")
			
			do {
				try managedContext.save()
			} catch let error as NSError {
				print("TrustedSite.addDomain error: \(error), \(error.userInfo)")
			}
			
			return
		}
		print("TrustedSite.addDomain: Domain already exists in TrustedSites")
	}
	
	func removeDomain(_ domain: String) {
		if let site = self.getTrustedSite(domain) {
			guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
				return
			}
			let managedContext = appDelegate.persistentContainer.viewContext
			managedContext.delete(site)
			
			do {
				try managedContext.save()
			} catch let error as NSError {
				print("TrustedSite.removeDomain error: \(error), \(error.userInfo)")
			}
			
			return
		}
		print("TrustedSite.removeDomain: Domain does not exist in TrustedSites")
	}
	
	/// Fetch the current TrustedSites entity from CoreData
	private func getTrustedSitesEntity() -> [NSManagedObject]? {
		guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
			return nil
		}
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrustedSites")
		do {
			return try managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			print("TrustedSite.getTrustedSites error: \(error), \(error.userInfo)")
			return nil
		}
	}
	
	/// Trigger a CoreData context save
	private func saveContext(){
		guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
			return
		}
		let managedContext = appDelegate.persistentContainer.viewContext
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("TrustedSite.saveContext error: \(error), \(error.userInfo)")
		}
	}
}
