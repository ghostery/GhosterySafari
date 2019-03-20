//
//  DictionaryExtensions.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

extension Dictionary {
    func reduceValues<B>(reduce: (Value) -> B) -> Dictionary<Key, B> {
        var reduceDict: Dictionary<Key,B> = [:]
        
        for key in self.keys {
            reduceDict[key] = reduce(self[key]!)
        }
        
        return reduceDict
    }
}

extension Dictionary where Value: Comparable {
    func sortedKeysAscending(_ ascending: Bool) -> [Key] {
        return self.sorted(by: { (one, two) -> Bool in
            return ascending ? one.value < two.value : one.value > two.value
        }).map({ (elem) -> Key in
            return elem.key
        })
    }
}
