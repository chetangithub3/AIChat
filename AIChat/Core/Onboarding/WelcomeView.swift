//
//  WelcomeView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 8/6/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(LogManager.self) private var logManager
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
            .screenAppearAnalytic(name: "WelcomeView")
        }
    }
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.signInSuccess(isNewUser: isNewUser))
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
        logManager.trackEvent(event: Event.signInPressed)
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
    enum Event: LoggableEvent {
        case signInPressed
        case signInSuccess(isNewUser: Bool)

        var eventName: String {
            switch self {
            case .signInPressed:      return "WelcomeView_Signin_Pressed"
            case .signInSuccess:     return "WelcomeView_SignIn_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signInSuccess(let isNewUser):
                return ["is_new_user": isNewUser]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
    .environment(AppState())
}
