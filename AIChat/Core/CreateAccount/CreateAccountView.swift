//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/3/25.
//

import SwiftUI

struct CreateAccountView: View {
    var title: String = "Create Account"
    var subtitle: String = "Dont lose your data! Connect to an SSO provider to save your account information"
    @State private var showSignInView: Bool = false
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
                }
        }
        .sheet(isPresented: $showSignInView) {
            CreateAccountView()
                .presentationDetents([.medium])
        }
        .padding()
        .padding(.top, 40)
    }
    private func signInPressed() {
    }
}

#Preview {
    CreateAccountView()
}
