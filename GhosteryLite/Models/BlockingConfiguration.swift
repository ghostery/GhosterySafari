//
// BlockingConfiguration
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

/// Provides data management for the `BlockingConfig` entity in CoreData
class BlockingConfiguration {
	
	var configType: Int? /// CoreData attribute
	var blockedCategories = [Int]() /// Converted from CoreData attribute of type String

	static let shared = BlockingConfiguration(type: .defaultBlocking)
	
	/// Blocking configuration types.  Custom or default blocking
	enum ConfigurationType: Int {
		case defaultBlocking
		case customBlocking
	}
	
	init(type: ConfigurationType) {
		configType = type.rawValue
		blockedCategories.append(Categories.advertising.rawValue)
		blockedCategories.append(Categories.audioVideoPlayer.rawValue)
		blockedCategories.append(Categories.comments.rawValue)
		blockedCategories.append(Categories.customerInteraction.rawValue)
		blockedCategories.append(Categories.essential.rawValue)
		blockedCategories.append(Categories.pornvertising.rawValue)
		blockedCategories.append(Categories.siteAnalytics.rawValue)
		blockedCategories.append(Categories.socialMedia.rawValue)
		
		self.setDefaultConfig(type: type)
	}
	
	/// Generates a list of the default blocked categories
	func defaultBlockedCategories() -> [Categories] {
		return [.advertising, .siteAnalytics, .pornvertising]
	}
	
	/// Fetches the configType property from the BlockingConfig entity of CoreData
	func getConfigType() -> Int {
		if let blockingConfig = self.getBlockingConfig() {
			if let config = blockingConfig.first {
				if let cfgType = config.value(forKey: "configType") as? Int {
					return cfgType
				}
			}
		}
		// If no configType found return defaultBlocking
		return ConfigurationType.defaultBlocking.rawValue
	}
	
	/// Update the configType property of BlockingConfig entity from CoreData
	/// - Parameter type: Configuration type
	func updateConfigType(type: ConfigurationType) {
		if let blockingConfig = self.getBlockingConfig() {
			// Update the existing BlockingConfig object
			if let config = blockingConfig.first {
				config.setValue(type.rawValue, forKeyPath: "configType")
				self.saveContext()
			}
		}
	}
	
	/// Get a list of blockedCategories from the BlockingConfig entity of CoreData
	func getBlockedCategories() -> [Int]? {
		if let blockingConfig = self.getBlockingConfig() {
			if let config = blockingConfig.first {
				if let cats = config.value(forKey: "blockedCategories") as? String {
					// Covert comma-separated string to [Int]
					return Utils.shared.stringToIntArray(cats)
				}
			}
		}
		return nil
	}
	
	/// Checks the blockedCategories list from the BlockingConfig entity of CoreData to see if the given category is blocked
	/// - Parameter category: The category to check
	func isCategoryBlocked(category: Categories) -> Bool {
		if let blockingConfig = self.getBlockingConfig() {
			if let config = blockingConfig.first {
				if let cats = config.value(forKey: "blockedCategories") as? String {
					let arr = Utils.shared.stringToIntArray(cats)
					return arr.contains(category.rawValue)
				}
			}
		}
		return false
	}
	
	/// Add or remove a category ID from the blockedCategories list
	/// - Parameters:
	///   - category: The category to block or unblock
	///   - blocked: The new blocked state of the category
	func updateBlockedCategory(category: Categories, blocked: Bool) {
		if let blockingConfig = self.getBlockingConfig() {
			// Get the existing BlockingConfig object
			if let config = blockingConfig.first {
				if let cats = config.value(forKey: "blockedCategories") as? String {
					var arr = Utils.shared.stringToIntArray(cats)
					// Category is blocked but not in the blockedCategories list
					if blocked && !arr.contains(category.rawValue) {
						// Add the category to the blockedCategories list
						arr.append(category.rawValue)
						config.setValue(Utils.shared.intArrayToString(arr), forKeyPath: "blockedCategories")
						self.saveContext()
					}
					// Category is allowed but currently in the blockedCategories list
					if !blocked && arr.contains(category.rawValue) {
						// Remove the category from the blockedCategories list
						if let index = arr.firstIndex(of: category.rawValue) {
							arr.remove(at: index)
							config.setValue(Utils.shared.intArrayToString(arr), forKeyPath: "blockedCategories")
						}
						self.saveContext()
					}
				}
			}
		}
	}
	
	/// Fetch the current BlockingConfig entity from CoreData
	private func getBlockingConfig() -> [NSManagedObject]? {
		guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
			return nil
		}
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BlockingConfig")
		do {
			return try managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			Utils.shared.logger("Error: \(error), \(error.userInfo)")
			return nil
		}
	}
	
	/// On init, set the default blocking config if it does not exist
	/// - Parameter type: The configuration type
	private func setDefaultConfig(type: ConfigurationType) {
		if let blockingConfig = self.getBlockingConfig() {
			if blockingConfig.isEmpty {
				guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
					return
				}
				let managedContext = appDelegate.persistentContainer.viewContext
				let entity = NSEntityDescription.entity(forEntityName: "BlockingConfig", in: managedContext)!
				let config = NSManagedObject(entity: entity, insertInto: managedContext)
				
				config.setValue(type.rawValue, forKeyPath: "configType")
				config.setValue(Utils.shared.intArrayToString(self.blockedCategories), forKeyPath: "blockedCategories")
				
				self.saveContext()
			}
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
			Utils.shared.logger("Error: \(error), \(error.userInfo)")
		}
	}
}
