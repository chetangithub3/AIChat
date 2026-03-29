//
//  UserManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/21/26.
//

import SwiftUI

@MainActor
@Observable
class UserManager {

    private(set) var currentUser: UserModel?
    private let remote: RemoteUserService
    private let local: LocalUserPersistence

    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
    }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        addCurentUserListerner(userId: user.userId)
    }
    private func addCurentUserListerner(userId: String) {
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                }
            } catch {
            }
        }
    }
    private func saveCurrentUserLocally() {
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
            } catch {
            }
        }
    }
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    func signOut() {
        currentUser = nil
    }
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
