//
//  AvatarModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/12/25.
//

import Foundation
import IdentifiableByString

struct AvatarModel: Codable, Hashable, Identifiable, StringIdentifiable {
    var id: String {
        avatarId
    }
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
        self.clickCount = clickCount
    }
    var characterDescription: String {
        AvatarModelDescriptionBuilder(avatar: self).characterDescription
    }
    mutating func updateImage(imageName: String) {
        profileImageName = imageName
    }
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
        case clickCount = "click_count"
    }
}

extension AvatarModel {
    static func newAvatar(name: String, option: CharacterOption, action: CharacterAction, location: CharacterLocation, authorId: String) -> Self {
        AvatarModel(
            avatarId: "avatar_ava_1",
            name: name,
            characterOption: option,
            characterAction: action,
            characterLocation: location,
            profileImageName: nil,
            authorId: authorId,
            dateCreated: Date(),
            clickCount: 0
        )
    }
    static let mocks: [Self] = [
        AvatarModel(
            avatarId: "avatar_ava_2",
            name: "Luna",
            characterOption: .cat,
            characterAction: .sleeping,
            characterLocation: .city,
            profileImageName: Constants.randomImageURLString,
            authorId: "user123",
            dateCreated: Date(),
            clickCount: 10
        ),
        AvatarModel(
            avatarId: "avatar_ava_3",
            name: "Bolt",
            characterOption: .dog,
            characterAction: .walking,
            characterLocation: .desert,
            profileImageName: Constants.randomImageURLString,
            authorId: "user456",
            dateCreated: Date().addingTimeInterval(-86400),
            clickCount: 5
        ),
        AvatarModel(
            avatarId: "avatar_ava_4",
            name: "Zorg",
            characterOption: .alien,
            characterAction: .crying,
            characterLocation: .sea,
            profileImageName: Constants.randomImageURLString,
            authorId: "user789",
            dateCreated: Date().addingTimeInterval(-3600),
            clickCount: 100
        ),
        AvatarModel(
            avatarId: UUID().uuidString,
            name: "Alex",
            characterOption: .human,
            characterAction: .sitting,
            characterLocation: .building,
            profileImageName: Constants.randomImageURLString,
            authorId: "user111",
            dateCreated: Date().addingTimeInterval(-604800),
            clickCount: 25
        )
    ]

    static var mock: Self {
        mocks.randomElement()!
    }
}

extension AvatarModel {
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "avatar_\(CodingKeys.avatarId.rawValue)": avatarId,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.characterOption.rawValue)": characterOption,
            "avatar_\(CodingKeys.characterAction.rawValue)": characterAction,
            "avatar_\(CodingKeys.characterLocation.rawValue)": characterLocation,
            "avatar_\(CodingKeys.profileImageName.rawValue)": profileImageName,
            "avatar_\(CodingKeys.authorId.rawValue)": authorId,
            "avatar_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "avatar_\(CodingKeys.clickCount.rawValue)": clickCount
        ]
        return dict.compactMapValues({ $0 })
    }
}
