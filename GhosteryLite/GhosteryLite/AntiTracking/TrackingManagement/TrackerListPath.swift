//
//  TrackerListPath.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/17/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

struct TrackerListPath {
    var path: String
    var bugId: Int
    
    func printContents() -> String {
        return "\(path): \(bugId)\n"
    }
}