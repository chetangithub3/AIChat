//
//  OnboardingCommunityView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/9/25.
//

import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
        VStack {
            Spacer()
            ImageLoaderView()
            introSection
                .frame(maxHeight: .infinity)
                .padding()
            continueButton
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytic(name: "OnboardingCommunityView")
    }

    private var continueButton: some View {
        NavigationLink {
            OnboardingColorPickerView()
        } label: {
            Text("Continue")
                .mainButtonStyle()
        }
    }
    private var introSection: some View {
        Group {
            Text("Build your")
            +
            Text(" community ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("and connect with people.\n\nHave ")
            +
            Text("meaningful conversations ")
                .fontWeight(.bold)
                .foregroundStyle(.accent)
            +
            Text("with 1000+ avatars")
        }
        .font(.title2)
    }
}

#Preview {
    OnboardingCommunityView()
        .previewEnvironment()
}
