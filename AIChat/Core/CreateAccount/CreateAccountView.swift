//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/3/25.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    var title: String = "Create Account"
    var subtitle: String = "Dont lose your data! Connect to an SSO provider to save your account information"
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                Text(subtitle)
                    .minimumScaleFactor(0.3)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            Spacer()
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black, cornerRadius: 30)
                .frame(height: 50)
                .anyButton(.pressable) {
                    signInPressed()
                }
        }
        .padding()
        .padding(.top, 40)
        .screenAppearAnalytic(name: "CreateAccountView")
    }
    enum Event: LoggableEvent {
        case authStart, authSuccess(user: UserAuthInfo, isNewUser: Bool), authSignInSuccess(user: UserAuthInfo, isNewUser: Bool), signInFail(error: Error)
        var eventName: String {
            switch self {
                case .authStart: return "CreateAccountView_AppleAuth_Start"
                case .authSuccess: return "CreateAccountView_AppleAuth_Success"
                case .authSignInSuccess: return "CreateAccountView_AppleAuth_SignInSuccess"
                case .signInFail: return "CreateAccountView_AppleAuth_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
                case .signInFail(error: let error):
                    return error.eventParameters
                case .authSuccess(user: let user, isNewUser: let isNew), .authSignInSuccess(user: let user, isNewUser: let isNew):
                    var dict = user.eventParameters
                    dict.merge(["is_new_user": isNew])
                    return dict
                default: return nil
            }
        }
        var type: LogType {
            switch self {
                case .signInFail: return .severe
                default: return .analytic
            }
        }
    }
    private func signInPressed() {
        logManager.trackEvent(event: Event.authStart)
        Task {
            do {
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.authSuccess(user: result.user, isNewUser: result.isNewUser))
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.authSignInSuccess(user: result.user, isNewUser: result.isNewUser))
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.signInFail(error: error))
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .previewEnvironment()
}
