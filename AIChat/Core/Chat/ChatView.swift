//
//  ChatView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/8/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(LogManager.self) private var logManager
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
        .screenAppearAnalytic(name: "ChatView")
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
        logManager.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatId = try getChatId()
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }
    func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try authManager.getAuthId()
            let chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            self.chat = chat
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    private func loadCurrentUser() {
        self.currentUser = userManager.currentUser
    }
    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
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
        logManager.trackEvent(event: Event.chatSettingsPressed)
        showChatSettings = AnyAppAlert(
            title: "Hello",
            message: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report user / Chat", role: .destructive) {
                           reportUserPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                           onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }
    private func reportUserPressed() {
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let userId = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: userId)
                logManager.trackEvent(event: Event.reportChatSuccess)
                showAlert = AnyAppAlert(title: "Reported successfully", message: "The chat will be reviewd.")
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(title: "Something went wrong", message: "Please check your network and try again")
            }
        }
    }
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                dismiss()
            } catch {
                showAlert = AnyAppAlert(title: "Something went wrong", message: "Please check your network and try again")
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
            }
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
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
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
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))

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
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: replyMessage))

                // upload AI chat
                try await chatManager.addChatMessage(chatId: chat.id, message: replyMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: replyMessage))
            } catch let error {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
            isGeneratingResponse = false
        }
    }
    enum ChatViewError: LocalizedError {
        case noChat
    }
    private func  createNewChat(userId: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
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
            VStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    if isChatDelayed(message: message) {
                        timeStampView(date: message.dateCreatedCalculated)
                    }
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserBackgroundColor: currentUser?.colorCalculated ?? .accent, imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onImagePressed
                    )
                    .id(message.id)
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
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
    private func isChatDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id}), chatMessages.indices.contains(index - 1) else {
            return false
        }
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        let threshold: TimeInterval = 60 * 45
        return timeDiff > threshold
    }
    private func timeStampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }
    private func onImagePressed() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        showProfileModal = true
    }
    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
            } catch {
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    enum Event: LoggableEvent {
        case loadAvatarStart, loadAvatarSuccess(avatar: AvatarModel?), loadAvatarFail(error: Error)
        case loadChatStart, loadChatSuccess(chat: ChatModel?), loadChatFail(error: Error)
        case loadMessagesStart, loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?), sendMessageFail(error: Error), sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel), sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case createChatStart
        case chatSettingsPressed
        case reportChatStart, reportChatSuccess, reportChatFail(error: Error)
        case deleteChatStart, deleteChatSuccess, deleteChatFail(error: Error)
        case avatarImagePressed(avatar: AvatarModel?)
        var eventName: String {
            switch self {
                case .loadAvatarStart:            return "ChatView_LoadAvatar_Start"
                case .loadAvatarSuccess:          return "ChatView_LoadAvatar_Success"
                case .loadAvatarFail:             return "ChatView_LoadAvatar_Fail"
                case .loadChatStart:              return "ChatView_LoadChat_Start"
                case .loadChatSuccess:            return "ChatView_LoadChat_Success"
                case .loadChatFail:               return "ChatView_LoadChat_Fail"
                case .loadMessagesStart:          return "ChatView_LoadMessages_Start"
                case .loadMessagesFail:           return "ChatView_LoadMessages_Fail"
                case .messageSeenFail:            return "ChatView_MessageSeen_Fail"
                case .sendMessageStart:           return "ChatView_SendMessage_Start"
                case .sendMessageFail:            return "ChatView_SendMessage_Fail"
                case .sendMessageSent:            return "ChatView_SendMessage_Sent"
                case .sendMessageResponse:        return "ChatView_SendMessage_Response"
                case .sendMessageResponseSent:    return "ChatView_SendMessage_ResponseSent"
                case .createChatStart:            return "ChatView_CreateChat_Start"
                case .chatSettingsPressed:        return "ChatView_ChatSettings_Pressed"
                case .reportChatStart:            return "ChatView_ReportChat_Start"
                case .reportChatSuccess:          return "ChatView_ReportChat_Success"
                case .reportChatFail:             return "ChatView_ReportChat_Fail"
                case .deleteChatStart:            return "ChatView_DeleteChat_Start"
                case .deleteChatSuccess:          return "ChatView_DeleteChat_Success"
                case .deleteChatFail:             return "ChatView_DeleteChat_Fail"
                case .avatarImagePressed:         return "ChatView_AvatarImage_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                    return avatar?.eventParameters
                case .loadAvatarFail(error: let error), .loadMessagesFail(error: let error), .loadChatFail(error: let error):
                    return error.eventParameters
                case .loadChatSuccess(chat: let chat):
                    return chat?.eventParameters
                case .sendMessageStart(chat: let chat, avatar: let avatar):
                    var dict = chat?.eventParameters ?? [:]
                    dict.merge(avatar?.eventParameters)
                    return dict
                case .sendMessageFail(error: let error): return error.eventParameters
                case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message), .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message), .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                    var dict = chat?.eventParameters ?? [:]
                    dict.merge(avatar?.eventParameters)
                    dict.merge(message.eventParameters)
                    return dict
                case .reportChatFail(error: let error), .deleteChatFail(error: let error):
                    return error.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .loadAvatarFail, .loadMessagesFail, .messageSeenFail, .reportChatFail, .deleteChatFail: return .severe
                case .sendMessageFail: return .warning
                default: return .analytic
            }
        }
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
