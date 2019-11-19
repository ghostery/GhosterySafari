//
// ArrayExtension
// GhosteryLite
//
// Ghostery Lite for Safari
// https://www.ghostery.com/
//
// Copyright 2019 Ghostery, Inc. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0
//

extension Array {
	func groupBy<B:Hashable>(key: (Element) -> B) -> Dictionary<B, [Element]>{
		var dict: Dictionary<B, [Element]> = [:]
		
		for elem in self {
			let key = key(elem)
			if var dict_array = dict[key] {
				dict_array.append(elem)
				dict[key] = dict_array
			}
			else {
				dict[key] = [elem]
			}
		}
		
		return dict
	}
	
	func groupAndReduce<B:Hashable, C>(byKey: (Element) -> B, reduce: ([Element]) -> C) -> Dictionary<B, C> {
		let dict = self.groupBy(key: byKey)
		var reduceDict: Dictionary<B,C> = [:]
		
		for key in dict.keys {
			reduceDict[key] = reduce(dict[key]!)
		}
		
		return reduceDict
	}
	
	func batch(size: Int) -> [[Element]] {
		var result: [[Element]] = []
		var temp: [Element] = []
		for i in 0..<count {
			if i % size == 0 {
				result.append(temp)
				temp = []
			}
			else {
				temp.append(self[i])
			}
		}
		if temp.count > 0 {
			result.append(temp)
		}
		return result
	}
	
	func isIndexValid(index: Int) -> Bool {
		return index >= 0 && index < self.count
	}
}

extension Array where Element: Comparable {
	mutating func remove(element: Element) {
		for i in 0..<self.count {
			//go backwards
			let index = count - 1 - i
			let item = self[index]
			if item == element {
				self.remove(at: index)
			}
		}
	}
}
