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
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
                .environment(delegate.dependencies.abTestManager)
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
                let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
                let options =  FirebaseOptions(contentsOfFile: plist)!
                FirebaseApp.configure(options: options)
            case .mock:
                // Mock build does not run Firebase
                return
            case .prod:
                let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
                let options =  FirebaseOptions(contentsOfFile: plist)!
                FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager

    init(config: BuildConfiguration) {
        switch config {
            case .dev:
                self.logManager = LogManager(services: [
                    ConsoleLogService(doPrintParameters: true),
                    FirebaseAnalyticsService(),
                    MixPanelService(token: Keys.mixPanelToken),
                    FirebaseCrashlyticsService()
                ])
                self.authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
                self.userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
                self.aiManager = AIManager(service: OpenAIService())
                self.avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
                self.chatManager = ChatManager(service: FirebaseChatService())
                self.abTestManager = ABTestManager(service: LocalAbTestService(), logManager: logManager)
            case .mock(let isSignedIn):
                self.logManager = LogManager(services: [
                    ConsoleLogService(doPrintParameters: true)
                ])
                self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock: nil), logManager: logManager)
                self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock: nil), logManager: logManager)
                self.aiManager = AIManager(service: MockAIService())
                self.avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
                self.chatManager = ChatManager(service: MockChatService())
                self.abTestManager = ABTestManager(service: MockABTestService(), logManager: logManager)
            case .prod:
                self.logManager = LogManager(services: [
                    FirebaseAnalyticsService(), MixPanelService(token: Keys.mixPanelToken)
                ])
                self.authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
                self.userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
                self.aiManager = AIManager(service: OpenAIService())
                self.avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
                self.chatManager = ChatManager(service: FirebaseChatService())
                self.abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
        }
        pushManager = PushManager(logManager: logManager)
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ABTestManager(service: MockABTestService()))
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock: nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock: nil)))
            .environment(AppState())
            .environment(LogManager(services: []))
            .environment(PushManager())
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()

    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager

    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock: nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock: nil))
        self.aiManager = AIManager(service: MockAIService())
        self.avatarManager = AvatarManager(service: MockAvatarService())
        self.chatManager = ChatManager(service: MockChatService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestService())
    }
}
