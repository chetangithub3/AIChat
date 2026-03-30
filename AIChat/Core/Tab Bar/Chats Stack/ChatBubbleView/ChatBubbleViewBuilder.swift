//
//  ChatBubbleViewBuilder.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/8/25.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var imageName: String?
    var onImagePressed: (() -> Void)?
    var body: some View {
        ChatBubbleView(
            showImage: !isCurrentUser,
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray5),
            text: message.content?.content ?? "",
            imageName: imageName,
            onImagePressed: onImagePressed
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 50 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 50)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is long content that goes onto multiple lines. It should be truncated appropriately. Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
                    createdAt: .now,
                    seenByIds: nil
                )
            )
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is long content that goes onto multiple lines. It should be truncated appropriately. Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
                    createdAt: .now,
                    seenByIds: nil
                ), isCurrentUser: true
            )
        }
        .padding()
    }
}
