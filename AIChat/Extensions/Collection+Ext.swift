//
//  Collection+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

extension Collection {
    func first(upto value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        let maxItems = Swift.min(count, value)
        return Array(prefix(maxItems))
    }
    func last(upto value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        let maxItems = Swift.max(count, value)
        return Array(prefix(maxItems))
    }
}
