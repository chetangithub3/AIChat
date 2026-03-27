//
//  AIChatApp.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/5/25.
//

import SwiftUI
import Firebase
@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
           AppView()
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        dependencies = Dependencies()
        return true
    }
}

@MainActor
struct Dependencies {
    var authManager: AuthManager
    var userManager: UserManager
    var aiManager: AIManager
    let avatarManager: AvatarManager
    init() {
        self.authManager = AuthManager(service: FirebaseAuthService())
        self.userManager = UserManager(services: ProductionUserServices())
        self.aiManager = AIManager(service: OpenAIService())
        self.avatarManager = AvatarManager(service: FirebaseAvatarService())
    }
}
