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
    @State private var showChatSettings: AnyAppAlert?
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                scrollViewSection
                textFieldSection
            }
        }
        .navigationTitle(avatar?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .anyButton {
                        onChatSettingsPressed()
                    }
            }
        }
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar)
                    .zIndex(999)
                    .animation(.bouncy, value: showProfileModal)
            }
        }
    }
    private func profileModal(_ avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subTitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription.capitalized) {
                showProfileModal = false
            }
            .transition(.slide)
    }
    private func onChatSettingsPressed() {
        showChatSettings = AnyAppAlert(
            title: "Hello",
            message: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report user / Chat", role: .destructive) {
                           //
                        }
                        Button("Delete Chat", role: .destructive) {
                           //
                        }
                    }
                )
            }
        )
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
        do {
            try TextValidationHelper.validateMessage(for: textFieldText)
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
        } catch let error {
            showAlert = AnyAppAlert(error: error)
        }
    }
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onImagePressed
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
    private func onImagePressed() {
        showProfileModal = true
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
