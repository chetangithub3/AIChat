//
//  ChatView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/8/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel? = .mock
    @State private var textFieldText: String = ""
    @State private var showChatSettings: AnyAppAlert?
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse = false
    var avatarId: String = AvatarModel.mock.avatarId
    @State var chat: ChatModel?
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    Image(systemName: "ellipsis")
                        .anyButton {
                            onChatSettingsPressed()
                        }
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
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenForChatMessages()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    private func listenForChatMessages() async {
        do {
            let chatId = try getChatID()
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            print("fefjwegjwejfe")
        }
    }
    func getChatID() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    private func loadChat() async {
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            print("success loading chat")
        } catch {
            print("error")
        }
    }
    private func loadCurrentUser() {
        self.currentUser = userManager.currentUser
    }
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("error loading av")
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
                    .disabled(isGeneratingResponse)
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
        Task {
            isGeneratingResponse = true
            do {
                    // necessary id
                let userId = try authManager.getAuthId()
                    // validate input chat message
                let textFieldMessage = textFieldText
                try TextValidationHelper.validateMessage(for: textFieldText)
                    // create new chat
                if chat == nil {
                    do {
                        chat = try await createNewChat(userId: userId)
                    } catch {
                        throw ChatViewError.noChat
                    }
                }
                // create user chat
                guard let chat else { throw ChatViewError.noChat}
                let message = ChatMessageModel.newUserMessage(chatId: chat.id, userId: userId, message: AIChatModel(role: .user, content: textFieldMessage))
                // upload chat
                try await chatManager.addChatMessage(chatId: chat.id, message: message)

                // clear text field and scroll down
                textFieldText = ""
                // generate AI reply
                var chats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.characterDescription {
                    let systemMessage = AIChatModel(
                        role: .system,
                        content: "You are a \(avatarDescription)"
                    )
                    chats.insert(systemMessage, at: 0)
                }
                let reply = try await aiManager.generateText(chats: chats)
                let replyMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: reply)

                // upload AI chat
                try await chatManager.addChatMessage(chatId: chat.id, message: replyMessage)
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
            isGeneratingResponse = false
        }
    }
    enum ChatViewError: LocalizedError {
        case noChat
    }
    private func  createNewChat(userId: String) async throws -> ChatModel {
        let newChat = ChatModel.new(userId: userId, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        defer {
            Task {
                await listenForChatMessages()
            }
        }
        return newChat
    }
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserBackgroundColor: currentUser?.colorCalculated ?? .accent, imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onImagePressed
                    )
                    .id(message.id)
                }
            }
            .rotationEffect(.degrees(180))
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .rotationEffect(.degrees(180))
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
    private func onImagePressed() {
        showProfileModal = true
    }
}

#Preview("Everything working") {
    NavigationStack {
        ChatView()
            .previewEnvironment()
    }
}

#Preview("Slow AI") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 5)))
            .previewEnvironment()
    }
}
#Preview("Failed AI generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 5, doesThrow: true)))
            .previewEnvironment()
    }
}
