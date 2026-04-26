//
//  CategoryRowTestOption.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/18/26.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden

    static var `default`: Self {
        .original
    }
}
