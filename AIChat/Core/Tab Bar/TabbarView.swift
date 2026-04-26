//
//  TabbarView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct TabbarView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(LogManager.self) private var logManager
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                }
            ProfileView(
                viewModel: ProfileViewModel(
                    authManager: authManager,
                    userManager: userManager,
                    avatarManager: avatarManager,
                    logManager: logManager,
                    aiManager: aiManager
                )
            )
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    TabbarView()
}
