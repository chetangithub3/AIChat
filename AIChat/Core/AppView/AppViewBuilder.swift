//
//  AppViewBuilder.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showOnboardingView: Bool
    @ViewBuilder var tabbarView: TabbarView
    @ViewBuilder var onboardingView: OnboardingView
    
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
        .onTapGesture {
            showOnboarding.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
