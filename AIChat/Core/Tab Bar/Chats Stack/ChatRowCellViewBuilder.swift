//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 10/12/25.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    var currentUserId: String?
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel
    var getLastMessge: () async -> ChatMessageModel
    @State private var avatar: AvatarModel?
    @State private var lastMessage: ChatMessageModel?
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadMessage: Bool = false
    private var isLoading: Bool {
        !(didLoadAvatar && didLoadMessage)
    }
    private var hasNewChat: Bool {
        guard let lastMessage, let currentUserId else { return false }
        return lastMessage.hasBeenSeenBy(userId: currentUserId)
    }
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: isLoading ? "xxxx xxxx xxxx" : lastMessage?.content,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await self.getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastMessage = await self.getLastMessge()
            didLoadMessage = true
        }
    }
}

#Preview {
    List {
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            return .mock
        }, getLastMessge: {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            return .mock
        })
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            .mock
        }, getLastMessge: {
            .mock
        })
    }
}
