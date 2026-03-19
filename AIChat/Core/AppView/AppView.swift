//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppView: View {
    @Environment(\.authService) private var authService
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
        if let user = authService.getAuthenticatedUser() {
            print("user already authenticated \(user.uid)")
        } else {
            do {
                let result = try await authService.signInAnonymously()
                print("Sign In anonymous  success: \(result.user.uid)")
            } catch {
                print("errro2")
            }
        }
    }
}

#Preview("Tabbar View") {
   AppView(appState: AppState(showOnboardingView: false))
}

#Preview("Onboarding View") {
    AppView(appState: AppState(showOnboardingView: true))
}
