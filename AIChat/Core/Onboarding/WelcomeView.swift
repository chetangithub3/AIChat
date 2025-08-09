//
//  WelcomeView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct WelcomeView: View {
    var imageURLString: String = Constants.randomImageURLString
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageURLString)
                    .ignoresSafeArea()
                titleSection
                    .padding(.top)
                signInButtons
                policyLinks
                    .padding(.top)
            }
        }
    }
    
    private var signInButtons: some View {
        VStack(spacing: 4) {
            NavigationLink {
                OnboardingCompleteView()
            } label: {
                Text("Get Started")
                    .mainButtonStyle()
            }
            Text("Already have an account? Log in.")
                .foregroundColor(.secondary)
                .underline()
                .tappableTextWithAction(tapAction, scale: 1.2)
        }
    }

    private func tapAction() {
        print("hello")
    }

    private var policyLinks: some View {
        HStack {
            Link(destination: URL(string: Constants.termsAndConditionsString)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(Color.gray)
                .frame(width: 10, height: 10)
            
            Link(destination: URL(string: Constants.privacyPolicyString)!) {
                Text("Privacy Policy")
            }
        }
        .foregroundColor(.accentColor)
    }

    private var titleSection: some View {
        VStack {
            Text("AI Chat 🤙🏼")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            Text("Youtube @Swiftfulthinking")
                .font(.caption2)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WelcomeView()
}
