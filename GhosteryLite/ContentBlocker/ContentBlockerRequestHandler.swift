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
        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
