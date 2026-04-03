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
