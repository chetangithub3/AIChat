//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @State var appState: AppState = AppState()
    var body: some View {
        AppViewBuilder(
            showOnboardingView: appState.showOnboardingView,
            onboardingView: {
                WelcomeView()
            },
            tabbarView: {
                TabbarView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showOnboardingView) { _, showOnboardingView in
            if showOnboardingView {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    private func checkUserStatus() async {
        if let user = authManager.auth {
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("Tabbar View") {
   AppView(appState: AppState(showOnboardingView: false))
        .environment(AuthManager(service: MockAuthService(user: .mock)))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview("Onboarding View") {
    AppView(appState: AppState(showOnboardingView: true))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
