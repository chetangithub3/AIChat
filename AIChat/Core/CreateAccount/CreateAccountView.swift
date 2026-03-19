//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/3/25.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.authService) private var authService
    var title: String = "Create Account"
    var subtitle: String = "Dont lose your data! Connect to an SSO provider to save your account information"
    var onDidSignIn: ((_ isNewUser: Bool) -> ())?
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
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
    }
    private func signInPressed() {
        Task {
            do {
                let result = try await authService.signInApple()
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                print("Error signing in")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
