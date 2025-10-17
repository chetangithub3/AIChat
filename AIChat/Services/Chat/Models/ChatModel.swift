//
//  ChatModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation

struct ChatModel: Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateUpdated: Date

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
