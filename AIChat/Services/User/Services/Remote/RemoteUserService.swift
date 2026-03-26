//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

import SwiftUI

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}
