//
//  FirebaseChatService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/31/26.
//

import SwiftfulFirestore
import FirebaseFirestore

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    var chatReportsCollection: CollectionReference {
        Firestore.firestore().collection("chat_reports")
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
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await messagesCollection(chatId: chatId).document(messageId).updateData([
            ChatMessageModel.CodingKeys.seenByIds.rawValue: FieldValue.arrayUnion([userId])
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
    func deleteChat(chatId: String) async throws {
        async let deleteChat: () = collection.deleteDocument(id: chatId)
        async let deleteMessages: () = messagesCollection(chatId: chatId).deleteAllDocuments()
        let (_, _) =  await (try deleteChat, try deleteMessages)
    }
    func deleteAllChatsForUser(userId: String) async throws {
        let allChats = try await getAllChats(userId: userId)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in allChats {
                group.addTask {
                    try await deleteChat(chatId: chat.id)
                }
            }
            try await group.waitForAll()
        }
    }
    func reportChat(report: ChatReportModel) async throws {
        try await chatReportsCollection.setDocument(document: report)
    }
}
