//
// ContentBlockerRequestHandler
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
	/// Tells the extension to prepare for a host app’s request.
	/// - Parameter context: Extension context
	func beginRequest(with context: NSExtensionContext) {
		let blockList = Constants.AssetsFolderURL?.appendingPathComponent(Constants.ContentBlockerLists.standard.rawValue)
		let attachment = NSItemProvider(contentsOf: blockList)
		
		let item = NSExtensionItem()
		item.attachments = [attachment] as? [NSItemProvider]

		context.completeRequest(returningItems: [item], completionHandler: { (expired) -> Void in
			Utils.logger("Successfully reloaded static block list. (Expired? \(expired))")
		})
	}
}
