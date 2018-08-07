//
//  TrackerListHosts.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/19/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

struct TrackerListHosts {
    var rootNode = TrieNode<Int>()

    func populate(_ jsonData: [String: AnyObject]) {
        populate(rootNode, jsonData: jsonData)
    }
    
    fileprivate func populate(_ node: TrieNode<Int>, jsonData: [String: AnyObject]) {
        for (key, value) in jsonData {
            if key == "$" {
                // Leaf node found. Contains the bug/tracker ID.
                if let bugId = value as? NSNumber {
                    node.value = bugId.intValue
                }
            }
            else {
                let childNode = TrieNode<Int>()
                node.addNode(key, newNode: childNode)
                if let childJsonData = value as? [String: AnyObject] {
                    populate(childNode, jsonData: childJsonData)
                }
            }
        }
    }
    
    func isMatch(_ reverseHost: [String]) -> Int {
        var currentNode = rootNode
        for key in reverseHost {
            if let nextNode = currentNode.getNode(key) {
                currentNode = nextNode
                if let nodeValue = currentNode.value {
                    // found
                    return nodeValue
                }
            }
            else {
                break
            }
        }
        
        return -1
    }

    func printContents() -> String {
        return printContents(rootNode, indent: 1)
    }

    func printContents(_ node: TrieNode<Int>, indent: Int) -> String {
        var output = ""
        
        let spacing = String(repeating: " ", count: indent)
        if node.value != nil {
            output += "\(spacing)\(node.value!)\n"
        }
        
        for (key, value) in node.nodes {
            output += "\(spacing)\(key)\n"
            output += printContents(value, indent: indent + 2)
        }
        
        return output
    }
}
