//
//  ChatView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/8/25.
//

import SwiftUI

struct ChatView: View {
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel? = .mock
    @State private var currentUser: UserModel? = .mock
    @State private var textFieldText: String = ""
    @State private var showChatSettings = false
    @State private var scrollPosition: String?
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .anyButton {
                        showChatSettings = true
                    }
            }
        }
        .confirmationDialog("", isPresented: $showChatSettings) {
            Button("Report user / Chat", role: .destructive) {
                
            }
            Button("Delete Chat", role: .destructive) {
                
            }
        } message: {
           Text("What would you like to do?")
        }

    }
    private var textFieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .padding(.trailing, 40)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onSendMessagePressed()
                    }
            })
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                      RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    private func onSendMessagePressed() {
        let message = ChatMessageModel(
            id: UUID().uuidString,
            chatId: UUID().uuidString,
            authorId: currentUser?.userId,
            content: textFieldText,
            createdAt: .now,
            seenByIds: nil
        )
        chatMessages.append(message)
        scrollPosition = message.id
        textFieldText = ""
    }
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName
                    )
                        .id(message.id)
                }
            }
            .rotationEffect(.degrees(180))
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .frame(maxWidth: .infinity)
        }
        .rotationEffect(.degrees(180))
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
