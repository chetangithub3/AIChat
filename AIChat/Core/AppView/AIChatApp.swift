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
                .environment(delegate.dependencies.chatManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let config: BuildConfiguration
#if MOCK
        config = .mock(isSignedIn: true)
#elseif DEV
        config = .dev
#else
        config = .prod
       
#endif
        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }
}

enum BuildConfiguration {
    case dev, mock(isSignedIn: Bool), prod
    
    func configure() {
        switch self {
            case .dev:
                let plist = Bundle.main.path(forResource: "GoogleServie-Info-Dev", ofType: "plist")!
                let options =  FirebaseOptions(contentsOfFile: plist)!
                FirebaseApp.configure(options: options)
            case .mock(let isSignedIn):
                //Mock build does not run Firebase
            case .prod:
                let plist = Bundle.main.path(forResource: "GoogleServie-Info-Prod", ofType: "plist")!
                let options =  FirebaseOptions(contentsOfFile: plist)!
                FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependencies {
    var authManager: AuthManager
    var userManager: UserManager
    var aiManager: AIManager
    var avatarManager: AvatarManager
    var chatManager: ChatManager

    init(config: BuildConfiguration) {
        switch config {
            case .dev:
                self.authManager = AuthManager(service: FirebaseAuthService())
                self.userManager = UserManager(services: ProductionUserServices())
                self.aiManager = AIManager(service: OpenAIService())
                self.avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
                self.chatManager = ChatManager(service: FirebaseChatService())
            case .mock(let isSignedIn):
                self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock: nil))
                self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock: nil))
                self.aiManager = AIManager(service: MockAIService())
                self.avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
                self.chatManager = ChatManager(service: MockChatService())
            case .prod:
                self.authManager = AuthManager(service: FirebaseAuthService())
                self.userManager = UserManager(services: ProductionUserServices())
                self.aiManager = AIManager(service: OpenAIService())
                self.avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
                self.chatManager = ChatManager(service: FirebaseChatService())
        }
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock: nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock: nil)))
            .environment(AppState())
    }
}
