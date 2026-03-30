//
//  ChatManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/30/26.
//

import Foundation

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
    }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
    }
}

import SwiftfulFirestore
import FirebaseFirestore

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)

        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateUpdated.rawValue: Date.now
        ])
    }
}

@MainActor
@Observable
class ChatManager {
    let service: ChatService
    init(service: ChatService) {
        self.service = service
    }
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
}
