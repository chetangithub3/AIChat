//
//  MockLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/29/26.
//

import SwiftUI

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    let avatars: [AvatarModel]
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    func addRecentAvatar(avatar: AvatarModel) throws {
    }
    func getRecentAvatars() throws -> [AvatarModel] {
        avatars.shuffled()
    }
}
