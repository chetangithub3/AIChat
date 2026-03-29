//
//  LocalUserPersistence.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

import SwiftUI

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
