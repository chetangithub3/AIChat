//
//  ChatsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks

    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil, // todo
                        chat: chat) {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            return .mock
                        } getLastMessge: {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            return .mock
                        }
                        .anyButton(.highlight, action: chatButtonPressed)
                }
            }
            .navigationTitle("Chats")
        }
    }
    func chatButtonPressed() {
    }
}

#Preview {
    ChatsView()
}
