//
//  ChatManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/30/26.
//

import Foundation

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
    }
}

import SwiftfulFirestore
import FirebaseFirestore

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
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
}
