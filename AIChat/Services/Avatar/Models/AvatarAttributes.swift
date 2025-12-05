//
//  CharacterOption.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//


enum CharacterOption: String, CaseIterable {
    case cat
    case dog
    case alien
    case human

    static var `default`: Self {
        .alien
    }

    var startsWithAVowel: Bool {
        ["a", "e", "i", "o", "u"].contains(self.rawValue.lowercased().first!)
    }
}

enum CharacterAction: String, CaseIterable, Hashable {
    case sitting
    case crying
    case walking
    case sleeping

    static var `default`: Self {
        .walking
    }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case city
    case desert
    case sea
    case building
    case staduim

    static var `default`: Self {
        .desert
    }
}