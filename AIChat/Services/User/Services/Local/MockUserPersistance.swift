//
//  MockUserPersistence.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

struct MockUserPersistence: LocalUserPersistence {
    let user: UserModel?

    func getCurrentUser() -> UserModel? {
        user
    }

    func saveCurrentUser(user: UserModel?) throws {
    }
}
