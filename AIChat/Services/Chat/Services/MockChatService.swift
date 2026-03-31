//
//  MockChatService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/31/26.
//

import SwiftUI
 
struct MockChatService: ChatService {
    func reportChat(report: ChatReportModel) async throws {
    }
    func deleteChat(chatId: String) async throws {
    }
    func deleteAllChatsForUser(userId: String) async throws {
    }
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
