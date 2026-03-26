//
//  UserManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/21/26.
//

import SwiftUI
protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}

struct MockUserService: UserService {

    let currentUser: UserModel?

    init(user: UserModel? = nil) {
        self.currentUser = user
    }

    func saveUser(user: UserModel) async throws {

    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }

    func deleteUser(userId: String) async throws {

    }

    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {

    }
}
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }

    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}

@MainActor
@Observable
class UserManager {

    private(set) var currentUser: UserModel?
    private let service: UserService

    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        addCurentUserListerner(userId: user.userId)
    }
    private func addCurentUserListerner(userId: String) {
        Task {
            do {
                for try await value in service.streamUser(userId: userId) {
                    self.currentUser = value
                    print("Success - useriD: \(value.userId)")
                }
            } catch {
                print("Error attaching user listener: \(error)")
            }
        }
    }
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await service.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    func signOut() {
        currentUser = nil
    }
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: uid)
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
