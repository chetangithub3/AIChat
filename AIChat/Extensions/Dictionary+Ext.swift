//
//  Dictionary+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/3/26.
//

import Foundation
extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self.map( { (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
}
extension Dictionary where Key == String {
    mutating func first(upTo maxItems: Int) {
        guard maxItems >= 0 else { return }
        var result: [String: Value] = [:]
        var count = 0
        for (key, value) in self {
            if count >= maxItems { break }
            result[key] = value
            count += 1
        }
        self = result
    }
}
