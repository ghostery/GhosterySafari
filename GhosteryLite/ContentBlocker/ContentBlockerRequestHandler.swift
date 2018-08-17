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
		let rules = AntiTrackingManager.shared.contentBlokerRules()
		
        let item = NSExtensionItem()
        item.attachments = rules

        context.completeRequest(returningItems: [item], completionHandler: nil)
    }

}
