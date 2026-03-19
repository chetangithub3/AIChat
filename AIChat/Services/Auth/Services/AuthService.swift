//
//  AuthService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/20/26.
//

import SwiftUI

protocol AuthService: Sendable {
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

extension EnvironmentValues {
    @Entry var authService: AuthService = MockAuthService()
}
