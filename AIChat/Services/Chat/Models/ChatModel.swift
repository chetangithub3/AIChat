//
//  ChatModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, Sendable, Hashable, StringIdentifiable {
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
                userId: UserAuthInfo.mock.uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: Date().adding(days: -3),
                dateUpdated: Date().adding(days: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock.uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: Date().adding(days: -2),
                dateUpdated: Date().adding(days: -1)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock.uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: Date().adding(days: -1),
                dateUpdated: Date().adding(hours: -10)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock.uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: Date().adding(hours: -6),
                dateUpdated: Date().adding(hours: -2)
            ),
            ChatModel(
                id: UUID().uuidString,
                userId: UserAuthInfo.mock.uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: Date().adding(hours: -1),
                dateUpdated: Date()
            )
        ]
    }
    static var mock: ChatModel {
        mocks[0]
    }
}
extension ChatModel {
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "chat_\(CodingKeys.id.rawValue)": id,
            "chat_\(CodingKeys.userId.rawValue)": userId,
            "chat_\(CodingKeys.avatarId.rawValue)": avatarId,
            "chat_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "chat_\(CodingKeys.dateUpdated.rawValue)": dateUpdated
        ]
        return dict.compactMapValues { $0 }
    }
}
