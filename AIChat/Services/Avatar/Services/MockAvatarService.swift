//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

import SwiftUI
struct MockAvatarService: AvatarService {
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.filter({ avatar in
            avatar.characterOption == category
        }).shuffled()
    }
    func getPopularAvatars() async throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
    }
}
