//
//  FileManagerUserPersistance.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

import SwiftUI

struct FileManagerUserPersistance: LocalUserPersistance {
    private let userDocumentKey = "current_user"
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, user)
    }
}
