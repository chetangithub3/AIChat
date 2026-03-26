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
                .environment(delegate.authManager)
                .environment(delegate.userManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var authManager: AuthManager!
    var userManager: UserManager!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        return true
    }
}
