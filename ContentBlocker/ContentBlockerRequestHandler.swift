//
//  ContentBlockerRequestHandler.swift
//  ContentBlocker
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let item = NSExtensionItem()
		
		let groupStorageFolder: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppsGroupID)
		let assetsFolder: URL? = groupStorageFolder?.appendingPathComponent("BlockListAssets")
		
		let p = assetsFolder?.appendingPathComponent("currentBlockList.json")

		let attachment = NSItemProvider(contentsOf: p)
		item.attachments = [attachment] as? [NSItemProvider]

		context.completeRequest(returningItems: [item], completionHandler: {
			(expired) -> Void in

			print("Successfully reloaded static blocker list. (Expired? \(expired))")
		})
	}

}
