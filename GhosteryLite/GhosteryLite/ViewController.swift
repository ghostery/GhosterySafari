//
//  ViewController.swift
//  GhosteryLite
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa
import SafariServices

class ViewController: NSViewController {

	@IBOutlet var adCheckbox: NSButton!
	@IBOutlet var siteAnalyticsCheckbox: NSButton!
	@IBOutlet var customInterCheckbox: NSButton!
	@IBOutlet var socialMediaCheckbox: NSButton!
	@IBOutlet var essentialCheckbox: NSButton!
	@IBOutlet var audioVideoCheckbox: NSButton!
	@IBOutlet var adultCheckbox: NSButton!
	@IBOutlet var commentsCheckbox: NSButton!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

/*
	func merge(files: [String], completion: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async {

			var finalJSON = [[String: Any]]()
			for f in files {
				if let url = self.getFilePath(fileName: f) {
					let nextChunk: [[String:Any]]? = FileManager.default.readJsonFile(at: url)
					if let n = nextChunk {
						finalJSON.append(contentsOf: n)
					}
				}
			}
			let groupIdentifier = "2UYYSSHVUH.Gh.GhosteryLite"
			
			let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
			let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
			let categoryAssetsFolder: URL? = assetsFolder?.appendingPathComponent("BlockListByCategory")
			let currentBlockList = assetsFolder?.appendingPathComponent("currentBlockList.json")
			FileManager.default.createDirectoryIfNotExists(assetsFolder, withIntermediateDirectories: true)
			FileManager.default.writeJsonFile(at: currentBlockList, with: finalJSON)
			DispatchQueue.main.async {
				completion()
			}
		}
	}
*/
//	func merge(completion: @escaping () -> Void) {
//		DispatchQueue.global(qos: .background).async {
//			let groupIdentifier = "2UYYSSHVUH.Gh.GhosteryLite"
//
//			let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
//			let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
//			let categoryAssetsFolder: URL? = assetsFolder?.appendingPathComponent("BlockListByCategory")
//			let currentBlockList = assetsFolder?.appendingPathComponent("currentBlockList.json")
//
//			if let bundledFilterListPath = Bundle.main.path(forResource: "cat_advertising", ofType: "json", inDirectory: "BlockListAssets/BlockListByCategory") {
//				do {
//					FileManager.default.createDirectoryIfNotExists(assetsFolder, withIntermediateDirectories: true)
//					if !FileManager.default.fileExists(atPath: (currentBlockList?.path)!) {
//						try FileManager.default.copyItem(atPath: bundledFilterListPath, toPath: (currentBlockList?.path)!)
//					}
//					DispatchQueue.main.async {
//						completion()
//					}
//				} catch {
//					print("error: \(error)")
//				}
//			}
//		}
//	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		adCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.advertising) ? 1 : 0)
		audioVideoCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.audioVideoPlayer) ? 1 : 0)
		commentsCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.comments) ? 1 : 0)
		customInterCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.customerInteraction) ? 1 : 0)
		essentialCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.essential) ? 1 : 0)
		adultCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.pornvertising) ? 1 : 0)
		siteAnalyticsCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.siteAnalytics) ? 1 : 0)
		socialMediaCheckbox.state = NSControl.StateValue(GlobalConfigDataSource.shared.isCategoryBlocked(.socialMedia) ? 1 : 0)

		SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "Gh.GhosteryLite.ContentBlocker") { (state, error) in
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@IBAction func categoryPressed(sender: NSButton) {
		var modifiedCat: CategoryType?
		switch sender.tag {
		case 1:
			modifiedCat = .advertising
			print("Supported category")
		case 2:
			modifiedCat = .audioVideoPlayer
		case 3:
			modifiedCat = .comments
		case 4:
			modifiedCat = .customerInteraction
		case 5:
			modifiedCat = .essential
		case 6:
			modifiedCat = .pornvertising
		case 7:
			modifiedCat = .siteAnalytics
		case 8:
			modifiedCat = .socialMedia
		case 9:
			modifiedCat = .uncategorized
		default:
			print("Unsupported category")
		}
		if let m = modifiedCat {
			let _ = GlobalConfigDataSource.shared.changeCategoryStatus(m, status: sender.state.rawValue == 0 ? false : true)
			AntiTrackingManager.shared.reloadContentBlocker()
		}
	}

}

