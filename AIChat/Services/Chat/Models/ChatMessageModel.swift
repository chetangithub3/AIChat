//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import Foundation
struct ChatMessageModel {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let createdAt: Date?
    let seenByIds: [String]?

    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
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
    func hasBeenSeenBy(userId: String) -> Bool {
        if let seenByIds = seenByIds {
            return seenByIds.contains(userId)
        }
        return false
    }
    static var mocks: [ChatMessageModel] {
          [
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: "user_001",
                  content: "Hey! How’s your project going?",
                  createdAt: Date().adding(days: -2, hours: -3),
                  seenByIds: ["user_002"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: "user_002",
                  content: "Pretty good! Just fixing some bugs right now 😅",
                  createdAt: Date().adding(days: -2, hours: -2, minutes: -40),
                  seenByIds: ["user_001"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_001",
                  authorId: "user_001",
                  content: "Nice! Send me a build when ready 🚀",
                  createdAt: Date().adding(days: -2, hours: -2, minutes: -20),
                  seenByIds: ["user_002"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_002",
                  authorId: "user_003",
                  content: "Morning! Did you check the new designs?",
                  createdAt: Date().adding(hours: -5),
                  seenByIds: ["user_004", "user_005"]
              ),
              ChatMessageModel(
                  id: UUID().uuidString,
                  chatId: "chat_002",
                  authorId: "user_004",
                  content: "Yes! They look fantastic 👏",
                  createdAt: Date().adding(hours: -4, minutes: -30),
                  seenByIds: ["user_003"]
              )
          ]
      }
      static var mock: ChatMessageModel {
          mocks[0]
      }
}
