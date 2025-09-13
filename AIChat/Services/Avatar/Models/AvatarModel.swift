//
//  AvatarModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/12/25.
//

import Foundation

struct AvatarModel {

    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }
    var characterDescription: String {
        AvatarModelDescriptionBuilder(avatar: self).characterDescription
    }
}

enum CharacterOption: String {
    case cat
    case dog
    case alien
    case human

    static var `default`: Self {
        .alien
    }
}

enum CharacterAction: String {
    case sitting
    case crying
    case walking
    case sleeping

    static var `default`: Self {
        .walking
    }
}

enum CharacterLocation: String {
    case city
    case desert
    case sea
    case building
    case staduim

    static var `default`: Self {
        .desert
    }
}

extension AvatarModel {
    static let mocks: [AvatarModel] = [
        AvatarModel(
            avatarId: UUID().uuidString,
            name: "Luna",
            characterOption: .cat,
            characterAction: .sleeping,
            characterLocation: .city,
            profileImageName: Constants.randomImageURLString,
            authorId: "user123",
            dateCreated: Date()
        ),
        AvatarModel(
            avatarId: UUID().uuidString,
            name: "Bolt",
            characterOption: .dog,
            characterAction: .walking,
            characterLocation: .desert,
            profileImageName: Constants.randomImageURLString,
            authorId: "user456",
            dateCreated: Date().addingTimeInterval(-86400)
        ),
        AvatarModel(
            avatarId: UUID().uuidString,
            name: "Zorg",
            characterOption: .alien,
            characterAction: .crying,
            characterLocation: .sea,
            profileImageName: Constants.randomImageURLString,
            authorId: "user789",
            dateCreated: Date().addingTimeInterval(-3600)
        ),
        AvatarModel(
            avatarId: UUID().uuidString,
            name: "Alex",
            characterOption: .human,
            characterAction: .sitting,
            characterLocation: .building,
            profileImageName: Constants.randomImageURLString,
            authorId: "user111",
            dateCreated: Date().addingTimeInterval(-604800)
        )
    ]

    static var mock: AvatarModel {
        mocks[0]
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
        "A \(charaterOption.rawValue.capitalized) is \(characterAction.rawValue.capitalized) in the \(characterLocation.rawValue.capitalized)"
    }
}
