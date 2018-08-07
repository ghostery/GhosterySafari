//
//  TrackerListRegex.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/17/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

struct TrackerListRegex {
    var bugId:Int
    var regex:String

    func printContents() -> String {
        return "\(bugId): \(regex)\n"
    }
}