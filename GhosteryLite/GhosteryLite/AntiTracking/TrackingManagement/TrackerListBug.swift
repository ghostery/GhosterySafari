//
//  TrackerListBug.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 3/10/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

@objc class TrackerListBug : NSObject {
    var bugId: Int
    var appId: Int
    var url: String
    var isBlocked: Bool
    var timestamp: Double
    var endTimestamp: Double {
        didSet {
            // calculate latency the first time this is set
            if latency == 0 && endTimestamp > timestamp {
                self.latency = endTimestamp - timestamp
            }
        }
    }
    fileprivate(set) var latency: Double

    init(bugId: Int, appId: Int, url: String) {
        self.bugId = bugId
        self.appId = appId
        self.url = url
        self.isBlocked = false
        self.timestamp = 0
        self.endTimestamp = 0
        self.latency = 0
    }
}
