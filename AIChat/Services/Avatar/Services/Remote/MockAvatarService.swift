//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

import SwiftUI
struct MockAvatarService: RemoteAvatarService {
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
    }
    func removeAuthoIdFromAllAvatars(userId: String) async throws {
    }
    let avatars: [AvatarModel]
    let delay: Int
    let doesThrow: Bool
    init(avatars: [AvatarModel] = AvatarModel.mocks, delay: Int = 2, doesThrow: Bool = false) {
        self.avatars = avatars
        self.delay = delay
        self.doesThrow = doesThrow
    }
    func throwError() throws {
        if doesThrow {
            throw URLError(.unknown)
        }
    }
    func getAvatar(id: String) async throws -> AvatarModel {
        guard let avatar = avatars.first(where: { $0.id == id }) else {
            throw URLError(.noPermissionsToReadFile)
        }
        try throwError()
        return avatar
    }
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return avatars.shuffled()
    }
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return avatars.filter({ avatar in
            avatar.characterOption == category
        }).shuffled()
    }
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return avatars.shuffled()
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return avatars.shuffled()
    }
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
        try throwError()
    }
    func incrementAvatarClickCount(avatarId: String) async throws {
        try throwError()
    }
}
