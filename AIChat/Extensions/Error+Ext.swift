//
//  Error+Ext.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/6/26.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
