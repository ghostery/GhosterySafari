//
//  PageTrackersFound.swift
//  Ghostery
//
//  Created by Joe Swindler on 4/25/16.
//
//

import Foundation

struct PageTrackersFound {
    var pageTrackers = [Int: TrackerListBug]() // Bug ID is the key

    var count: Int {
        get {
            return pageTrackers.count
        }
    }
    
    mutating func addTracker(_ tracker: TrackerListBug) {
        pageTrackers[tracker.bugId] = tracker
    }
    
    func getTracker(_ bugId: Int) -> TrackerListBug? {
        return pageTrackers[bugId]
    }
    
    func getTracker(_ bugUrl: String) -> TrackerListBug? {
        for (_, trackerBug) in pageTrackers {
            if trackerBug.url == bugUrl {
                return trackerBug
            }
        }
        
        return nil
    }
    
    func appIdSet() -> Set<Int> {
        var set = Set<Int>()
        pageTrackers.forEach { (_, bug) in
            set.insert(bug.appId)
        }
        return set
    }
    
    mutating func removeAll() {
        pageTrackers.removeAll()
    }
    
    func printContents() -> String {
        var output = "\(pageTrackers.count) Total\n\n"
        for (_, trackerBug) in pageTrackers {
            output += "bugId: \(trackerBug.bugId)\n" +
                "appId: \(trackerBug.appId)\n" +
                "url: \(trackerBug.url)\n" +
                "timestamp: \(trackerBug.timestamp)\n" +
                "latency: \(trackerBug.latency)\n"
        }
        
        return output
    }
}
