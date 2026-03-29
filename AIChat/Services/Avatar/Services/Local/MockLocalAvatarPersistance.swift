//
//  MockLocalAvatarPersistance.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/29/26.
//

import SwiftUI

struct MockLocalAvatarPersistance: LocalAvatarPersistance {
    func addRecentAvatar(avatar: AvatarModel) throws {
    }
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
