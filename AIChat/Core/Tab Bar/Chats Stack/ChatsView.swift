//
//  ChatsView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct ChatsView: View {
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
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    private func loadChats() async {
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateUpdated, ascending: false)
        } catch {
            print("failed to load chats")
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
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("error loading recent avatars: \(error)")
        }
    }
    private func avatarPressed(avatar: AvatarModel) {
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
