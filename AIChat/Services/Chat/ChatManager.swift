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
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

struct MockChatService: ChatService {
    
    let chats: [ChatModel]
    let delay: Int
    let doesThrow: Bool
    init(chats: [ChatModel] = ChatModel.mocks, delay: Int = 2, doesThrow: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.doesThrow = doesThrow
    }
    func throwError() throws {
        if doesThrow {
            throw URLError(.unknown)
        }
    }
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return ChatMessageModel.mocks.randomElement()
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return chats
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in
        }
    }
    func createNewChat(chat: ChatModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
    }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
    }
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return chats.first(where: { $0.userId == userId && $0.avatarId == avatarId })
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
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await collection
            .getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.createdAt.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        return messages.first
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
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatId: chatId)
    }
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }
    func getLastMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
}
