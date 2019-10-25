//
// ContentBlockerRequestHandler.swift
// ContentBlocker
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
