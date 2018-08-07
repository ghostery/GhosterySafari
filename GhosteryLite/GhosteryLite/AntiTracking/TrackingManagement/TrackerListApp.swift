//
//  TrackerListApp.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/17/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

@objc class TrackerListApp : NSObject {
    var appId: Int
    var name: String = ""
    var category: String = ""
    var tags = [Int]()
    
//    func state(domain: String?) -> TrackerUIState {
//        if let domain = domain, let domainObj = DomainStore.get(domain: domain) {
//            if domainObj.trustedTrackers.contains(appId) {
//                return .trusted
//            }
//            else if domainObj.restrictedTrackers.contains(appId) {
//                return .restricted
//            }
//        }
//
//        if let state = TrackerStateStore.getTrackerState(appId: appId) {
//            if state.translatedState == .blocked {
//                return .blocked
//            }
//            else {
//                return .empty
//            }
//        }
//        else {
//            return .empty
//        }
//    }
//    
//    func prevState(domain: String?) -> TrackerUIState {
//        if let domain = domain, let domainObj = DomainStore.get(domain: domain) {
//            if domainObj.previouslyTrustedTrackers.contains(appId) {
//                return .trusted
//            }
//            else if domainObj.previouslyRestrictedTrackers.contains(appId) {
//                return .restricted
//            }
//        }
//        
//        if let state = TrackerStateStore.getTrackerState(appId: appId) {
//            if state.prevTranslatedState == .blocked {
//                return .blocked
//            }
//            else {
//                return .empty
//            }
//        }
//        else {
//            return .empty
//        }
//    }

    init(id: Int, jsonData: [String: AnyObject]) {
        self.appId = id
        
        if let appName = jsonData["name"] as? String {
            name = appName
        }
        
        if let appCategory = jsonData["cat"] as? String {
            category = appCategory
        }
        
        if let appTags = jsonData["tags"] as? [NSNumber] {
            for appTag in appTags {
                tags.append(appTag.intValue)
            }
        }
    }
    
    func printContents() -> String {
        var output = "\n id: \(appId)\n name: \(name)\n category: \(category)\n"
        if tags.count > 0 {
            output += " tags: "
            for tag in tags {
                output += "\(tag),"
            }
            output += "\n"
        }

        return output
    }
}
