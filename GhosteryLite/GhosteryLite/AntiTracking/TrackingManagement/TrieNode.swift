//
//  TrieNode.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/17/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

class TrieNode<T> {
    var nodes = [String:TrieNode<T>]()
    var value: T?
    
    func addNode(_ key: String, newNode: TrieNode) {
        nodes[key] = newNode
    }

    func getNode(_ key: String) -> TrieNode? {
        if let nodeKey = nodes[key] {
            return nodeKey
        }
        
        return nil
    }
}
