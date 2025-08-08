//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppView: View {
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
    }
}

#Preview("Tabbar View") {
   AppView(appState: AppState(showOnboardingView: false))
}

#Preview("Onboarding View") {
    AppView(appState: AppState(showOnboardingView: true))
}
