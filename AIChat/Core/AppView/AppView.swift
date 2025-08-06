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
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar view")
                }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding view")
                }
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
