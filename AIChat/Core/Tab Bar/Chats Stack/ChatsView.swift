//
//  ChatsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil, // todo
                        chat: chat) {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            return .mock
                        } getLastMessge: {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            return ChatMessageModel.mocks.randomElement()!
                        }
                        .anyButton(.highlight) {
                            chatButtonPressed(chat: chat)
                        }
                }
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModules(path: $path)
        }
    }
    func chatButtonPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
}

#Preview {
    ChatsView()
}
