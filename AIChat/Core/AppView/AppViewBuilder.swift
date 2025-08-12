//
//  AppViewBuilder.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showOnboardingView: Bool
    @ViewBuilder var onboardingView: OnboardingView
    @ViewBuilder var tabbarView: TabbarView
    var body: some View {
        ZStack {
            if showOnboardingView {
                onboardingView
                    .transition(.move(edge: .leading))
            } else {
                tabbarView
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.smooth, value: showOnboardingView)
    }
}

private struct PreviewView: View {
    @State var showOnboarding: Bool = true
    var body: some View {
        AppViewBuilder(
            showOnboardingView: showOnboarding,
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding view")
                }
            }, tabbarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar view")
                }
            }
        )
        .onTapGesture {
            showOnboarding.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
