//
//  MockUserPersistance.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

struct MockUserPersistance: LocalUserPersistance {
    let user: UserModel?

    func getCurrentUser() -> UserModel? {
        user
    }

    func saveCurrentUser(user: UserModel?) throws {
    }
}
