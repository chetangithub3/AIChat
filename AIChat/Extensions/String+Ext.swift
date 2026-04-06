//
//  String+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/6/26.
//

import Foundation

extension String {
    static func convertToString(_ value: Any) -> String? {
        switch value {
            case let value as String: return value
            case let value as Int: return String(value)
            case let value as Float: return String(value)
            case let value as Double: return String(value)
            case let value as Bool: return String(value)
            case let value as Date: return value.formatted(date: .abbreviated, time: .shortened)
            case let arr as [Any]: return arr.compactMap({String.convertToString($0)}).sorted().joined(separator: ", ")
            case let value as CustomStringConvertible: return value.description
            default: return nil
        }
    }
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    func replaceSpacesWithUnderscore() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }
}
extension String {
   var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}
