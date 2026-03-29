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
    @State var recentAvatars: [AvatarModel] = AvatarModel.mocks
    @Environment(AvatarManager.self) private var avatarManager
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                        .removeListRowFormatting()
                }
                if chats.isEmpty {
                    noChatsView
                } else {
                    chatsView
                }
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModules(path: $path)
            .onAppear {
                loadRecentAvatars()
            }
        }
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
        path.append(.chat(avatarId: avatar.avatarId))
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
    func chatButtonPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
}

#Preview {
    ChatsView()
        .environment(AvatarManager(service: MockAvatarService()))
}
