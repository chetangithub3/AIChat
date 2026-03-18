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

    var plural: String {
        switch self {
            case .cat: return "cats"
            case .dog: return "dogs"
            case .alien: return "aliens"
            case .human: return "humans"
        }
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

struct AvatarModelDescriptionBuilder {
    let charaterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation

    init(charaterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.charaterOption = charaterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }

    init(avatar: AvatarModel) {
        self.init(
            charaterOption: avatar.characterOption ?? .default,
            characterAction: avatar.characterAction ?? .default,
            characterLocation: avatar.characterLocation ?? .default
        )
    }

    var characterDescription: String {
        "\(charaterOption.startsWithAVowel ? "An" : "A") \(charaterOption.rawValue.capitalized) is \(characterAction.rawValue.capitalized) in the \(characterLocation.rawValue.capitalized)"
    }
}
