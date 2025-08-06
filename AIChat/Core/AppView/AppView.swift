//
//  AppView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppView: View {
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    var body: some View {
        AppViewBuilder(
            showOnboardingView: showOnboarding,
            tabbarView: {
                TabbarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
    }
}

#Preview("Tabbar View") {
    AppView(showOnboarding: false)
}

#Preview("Onboarding View") {
    AppView(showOnboarding: true)
}
