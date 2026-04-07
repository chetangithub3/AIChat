//
//  ChatsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ChatsView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @State private var chats: [ChatModel] = []
    @State private var path: [NavigationPathOption] = []
    @State var recentAvatars: [AvatarModel] = []
    @Environment(AvatarManager.self) private var avatarManager
    @State private var isLoadingChats: Bool = true
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                        .removeListRowFormatting()
                }
                if !isLoadingChats {
                    if chats.isEmpty {
                        noChatsView
                    } else {
                        chatsView
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModules(path: $path)
            .screenAppearAnalytic(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    enum Event: LoggableEvent {
        case loadChatsStart, loadChatsSuccess(chatsCount: Int), loadChatsFail(error: Error)
        case loadRecentAvatarsStart, loadRecentAvatarsSuccess(avatarCount: Int), loadRecentAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel), chatPressed(chat: ChatModel)
        var eventName: String {
            switch self {
                case .loadChatsStart:  return "ChatsView_LoadChats_Start"
                case .loadChatsSuccess: return "ChatsView_LoadChats_Success"
                case .loadChatsFail: return "ChatsView_LoadChats_Fail"
                case .loadRecentAvatarsStart: return "ChatsView_LoadRecentAvatars_Start"
                case .loadRecentAvatarsSuccess: return "ChatsView_LoadRecentAvatars_Success"
                case .loadRecentAvatarsFail: return "ChatsView_LoadRecentAvatars_Fail"
                case .avatarPressed: return "ChatsView_Avatar_Pressed"
                case .chatPressed: return "ChatsView_Chat_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .loadChatsFail(error: let error), .loadRecentAvatarsFail(error: let error):
                    return error.eventParameters
                case .loadChatsSuccess(chatsCount: let chatCount):
                    return ["chats_count": chatCount]
                case .loadRecentAvatarsSuccess(avatarCount: let avatarCount):
                    return ["avatars_count": avatarCount]
                case .avatarPressed(avatar: let avatar):
                    return avatar.eventParameters
                case .chatPressed(chat: let chat):
                    return chat.eventParameters
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .loadChatsFail, .loadRecentAvatarsFail: return .severe
                default: return .analytic
            }
        }
    }
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateUpdated, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 70)
                                    .clipShape(.circle)
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                avatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
            }
        } header: {
            Text("Recents")
        }
    }
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadRecentAvatarsStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadRecentAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadRecentAvatarsFail(error: error))
        }
    }
    private func avatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    private var noChatsView: some View {
        Text("Your chats will appear here.")
            .foregroundStyle(.secondary)
            .font(.title3)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(40)
            .removeListRowFormatting()
    }
    private var chatsView: some View {
        ForEach(chats) { chat in
            ChatRowCellViewBuilder(
                currentUserId: authManager.auth?.uid, // todo
                chat: chat) {
                    try? await avatarManager.getAvatar(id: chat.avatarId)
                } getLastMessge: {
                    try? await chatManager.getLastMessage(chatId: chat.id)
                }
                .anyButton(.highlight) {
                    chatButtonPressed(chat: chat)
                }
        }
    }
    func chatButtonPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
}

#Preview("Has Data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("No Data") {
    ChatsView()
        .environment(
            AvatarManager(
                service: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}

#Preview("slow") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvironment()
}
