//
//  TrackerListHostPaths.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/19/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

struct TrackerListHostPaths {
    // This is a trie with leaf nodes that contain an array of TrackerListPath objects
    var rootNode = TrieNode<[TrackerListPath]>()
    
    func populate(_ jsonData: [String: AnyObject]) {
        populate(rootNode, jsonData: jsonData)
    }
    
    fileprivate func populate(_ node: TrieNode<[TrackerListPath]>, jsonData: [String: AnyObject]) {
        for (key, value) in jsonData {
            if key == "$" {
                // Leaf node found. Contains an array of path objects
                if let paths = value as? [AnyObject] {
                    for item in paths {
                        if let pathItem = item["path"] as? String {
                            if let bugItem = item["id"] as? NSNumber {
                                let trackerPath = TrackerListPath(path: pathItem, bugId: bugItem.intValue)
                                if node.value == nil {
                                    node.value = [TrackerListPath]()
                                }
                                node.value?.append(trackerPath)
                            }
                        }
                    }
                }
            }
            else {
                let childNode = TrieNode<[TrackerListPath]>()
                node.addNode(key, newNode: childNode)
                if let childJsonData = value as? [String: AnyObject] {
                    populate(childNode, jsonData: childJsonData)
                }
            }
        }
    }

    func isMatch(_ reverseHost: [String], path: String) -> Int {
        var urlPath = path
        if urlPath.characters.count < 2 {
            return -1 // empty or '/'
        }
        
        if rootNode.nodes.count == 0 {
            // list is not initialized yet
            debugPrint("List is not initialized yet.")
            return -1
        }
        
        // put all node paths in a list
        var currentNode = rootNode
        var paths = [TrackerListPath]()
        for key in reverseHost {
            if let nextNode = currentNode.getNode(key) {
                currentNode = nextNode
                if let nodeValue = currentNode.value {
                    for nodePath in nodeValue {
                        paths.append(nodePath)
                    }
                }
            }
            else {
                break
            }
        }
        
        // Strip starting '/'
        urlPath = String(urlPath.characters.dropFirst())
        for pathItem in paths {
            if urlPath.hasPrefix(pathItem.path) {
                // match found!
                return pathItem.bugId
            }
        }

        // not found
        return -1
    }
    
    func printContents() -> String {
        return printContents(rootNode, indent: 1)
    }

    func printContents(_ node: TrieNode<[TrackerListPath]>, indent: Int) -> String {
        var output = ""
        
        let spacing = String(repeating: " ", count: indent)
        if node.value != nil {
            if let pathList = node.value as [TrackerListPath]! {
                for item in pathList {
                    output += spacing
                    output += item.printContents()
                }
            }
        }
        
        for (key, value) in node.nodes {
            output += "\(spacing)\(key)\n"
            output += printContents(value, indent: indent + 2)
        }
        
        return output
    }
}
