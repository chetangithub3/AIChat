//
//  ChatModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, Sendable, StringIdentifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateUpdated: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
    }
    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }
    static func new(userId: String, avatarId: String) -> Self {
        Self.init(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateUpdated: .now
        )
    }
    static var mocks: [ChatModel] {
        [
            ChatModel(
                id: UUID().uuidString,
                userId: "user_001",
                avatarId: "avatar_sage",
                dateCreated: Date().adding(days: -3),
                dateUpdated: Date().adding(days: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: "user_002",
                avatarId: "avatar_neo",
                dateCreated: Date().adding(days: -2),
                dateUpdated: Date().adding(days: -1)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: "user_003",
                avatarId: "avatar_iris",
                dateCreated: Date().adding(days: -1),
                dateUpdated: Date().adding(hours: -10)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: "user_004",
                avatarId: "avatar_rio",
                dateCreated: Date().adding(hours: -6),
                dateUpdated: Date().adding(hours: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: "user_005",
                avatarId: "avatar_luna",
                dateCreated: Date().adding(hours: -1),
                dateUpdated: Date()
            )
        ]
    }
    static var mock: ChatModel {
        mocks[0]
    }
}
