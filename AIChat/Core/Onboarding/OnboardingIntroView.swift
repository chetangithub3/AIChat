//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 4/17/26.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(ABTestManager.self) private var abTestManager
    var body: some View {
        VStack {
            introSection
                .frame(maxHeight: .infinity)
                .padding()
            continueButton
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytic(name: "OnboardingIntroView")
    }

    private var continueButton: some View {
        NavigationLink {
            if abTestManager.activeTests.onboardingCommunityTest {
                OnboardingCommunityView()
            } else {
                OnboardingColorPickerView()
            }
        } label: {
            Text("Continue")
                .mainButtonStyle()
        }
    }
    private var introSection: some View {
        Group {
            Text("Make your")
            +
            Text(" avatars ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("and chat with them.\n\nHave ")
            +
            Text("real conversations ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("with AI generated responses")
        }
        .font(.title2)
    }
}
#Preview("Original flow") {
    OnboardingIntroView()
        .previewEnvironment()
}
#Preview("Onboarding community test") {
    OnboardingIntroView()
        .environment(ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
        .previewEnvironment()
}
