//
//  WelcomeView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var root
    var imageURLString: String = Constants.randomImageURLString
    @State private var showSignInView: Bool = false
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
            .toolbarVisibility(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSignInView) {
                CreateAccountView(
                    title: "Sign In",
                    subtitle: "Connnect to an existing account",
                    onDidSignIn: { isNewUser in
                        handleDidSignIn(isNewUser: isNewUser)
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
    private func handleDidSignIn(isNewUser: Bool) {
        if !isNewUser {
            root.updateViewState(showOnboarding: false)
        }
    }
    private var signInButtons: some View {
        VStack(spacing: 4) {
            NavigationLink {
                OnboardingColorPickerView()
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
        showSignInView = true
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
    NavigationStack {
        WelcomeView()
    }
    .environment(AppState())
}
