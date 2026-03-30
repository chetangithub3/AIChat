//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation
struct ChatMessageModel: Identifiable, Codable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let createdAt: Date?
    let seenByIds: [String]?

    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        createdAt: Date? = nil,
        seenByIds: [String]? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.createdAt = createdAt
        self.seenByIds = seenByIds
    }
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case createdAt = "created_at"
        case seenByIds = "seen_by_ids"
    }
    func hasBeenSeenBy(userId: String) -> Bool {
        if let seenByIds = seenByIds {
            return seenByIds.contains(userId)
        }
        return false
    }
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            createdAt: .now,
            seenByIds: [userId]
        )
    }
    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            createdAt: .now,
            seenByIds: []
        )
    }
    static var mocks: [ChatMessageModel] {
          [
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: UserAuthInfo.mock.uid,
                  content: AIChatModel(role: .system, content: "Hey! How’s your project going?"),
                  createdAt: Date().adding(days: -2, hours: -3),
                  seenByIds: ["user_002"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: AvatarModel.mock.avatarId,
                  content: AIChatModel(role: .user, content: "Pretty good! Just fixing some bugs right now 😅"),
                  createdAt: Date().adding(days: -2, hours: -2, minutes: -40),
                  seenByIds: ["user_001"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: UserAuthInfo.mock.uid,
                  content: AIChatModel(role: .system, content: "Nice! Send me a build when ready 🚀"),
                  createdAt: Date().adding(days: -2, hours: -2, minutes: -20),
                  seenByIds: ["user_002"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_002",
                  authorId: AvatarModel.mock.avatarId,
                  content: AIChatModel(role: .user, content: "Morning! Did you check the new designs?"),
                  createdAt: Date().adding(hours: -5),
                  seenByIds: ["user_004", "user_005"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_002",
                  authorId: UserAuthInfo.mock.uid,
                  content: AIChatModel(role: .system, content: "Yes! They look fantastic 👏"),
                  createdAt: Date().adding(hours: -4, minutes: -30),
                  seenByIds: ["user_003"]
              )
          ]
      }
      static var mock: ChatMessageModel {
          mocks[0]
      }
}
