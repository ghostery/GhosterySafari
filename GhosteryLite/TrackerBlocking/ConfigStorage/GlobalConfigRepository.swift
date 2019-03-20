//
//  GlobalConfigRepository.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/20/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import RealmSwift

enum ConfigurationType: Int {
	case custom
	case byDefault
}

class GlobalConfigObject: RealmSwift.Object {

	@objc dynamic var id = 0

	let configType = RealmOptional<Int>()
	public var blockedCategories = List<Int>()

	convenience init(type: ConfigurationType) {
		self.init()
		configType.value = type.rawValue
		blockedCategories.append(CategoryType.advertising.rawValue)
		blockedCategories.append(CategoryType.audioVideoPlayer.rawValue)
		blockedCategories.append(CategoryType.comments.rawValue)
		blockedCategories.append(CategoryType.customerInteraction.rawValue)
		blockedCategories.append(CategoryType.essential.rawValue)
		blockedCategories.append(CategoryType.pornvertising.rawValue)
		blockedCategories.append(CategoryType.siteAnalytics.rawValue)
		blockedCategories.append(CategoryType.socialMedia.rawValue)
	}

	override static func primaryKey() -> String? {
		return "id"
	}

	func defaultBlockedCategories() -> [CategoryType] {
		return [.advertising, .siteAnalytics, .pornvertising]
	}

}

class GlobalConfigRepository: RealmRepository<GlobalConfigObject, String> {
	
	static let shared = GlobalConfigRepository()

	public func globalConfig() -> GlobalConfigObject? {
		let list: [GlobalConfigObject] = self.findAll()
		return list.count > 0 ? list[0] as? GlobalConfigObject : nil
	}

	public func updateCategoryStatus(type: CategoryType, isOn: Bool) {
		if let c = self.globalConfig() {
			let realm = try! Realm()
			if isOn && !c.blockedCategories.contains(type.rawValue) {
				do {
					try realm.write {
						c.blockedCategories.append(type.rawValue)
					}
				} catch let e as NSError {
					print("Error on update -- \(e)")
				}
			}
			
			if !isOn && c.blockedCategories.contains(type.rawValue) {
				do {
					if let indx = c.blockedCategories.index(of: type.rawValue) {
						try realm.write {
							c.blockedCategories.remove(at: indx)
						}
					}
				} catch let e as NSError {
					print("Error on update -- \(e)")
				}
			}
		}
	}

	public func updateConfigType(_ type: ConfigurationType) {
		if let c = self.globalConfig() {
			let realm = try! Realm()
			do {
				try realm.write {
					c.configType.value = type.rawValue
				}
			} catch let e as NSError {
				print("Error on update -- \(e)")
			}
		}
	}
}
