//
//  CharacterOption.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/5/25.
//

enum CharacterOption: String, Codable, CaseIterable {
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

enum CharacterAction: String, Codable, CaseIterable, Hashable {
    case sitting
    case crying
    case walking
    case sleeping

    static var `default`: Self {
        .walking
    }
}

enum CharacterLocation: String, Codable, CaseIterable, Hashable {
    case city
    case desert
    case sea
    case building
    case staduim

    static var `default`: Self {
        .desert
    }
}

struct AvatarModelDescriptionBuilder: Codable {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation

    init(charaterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = charaterOption
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
        "\(characterOption.startsWithAVowel ? "An" : "A") \(characterOption.rawValue.capitalized) is \(characterAction.rawValue.capitalized) in the \(characterLocation.rawValue.capitalized)"
    }
    enum CodingKeys: String, CodingKey {
        case characterOption  = "character_option"
        case characterAction  = "character_action"
        case characterLocation = "character_location"
    }
    var eventParameters: [String: Any] {
        [
            "\(CodingKeys.characterOption.rawValue)": characterOption.rawValue,
            "\(CodingKeys.characterAction.rawValue)": characterAction.rawValue,
            "\(CodingKeys.characterLocation.rawValue)": characterLocation.rawValue,
            "character_description": characterDescription
        ]
    }
}
