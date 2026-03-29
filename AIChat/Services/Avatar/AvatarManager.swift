//
//  AvatarManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI

@MainActor
@Observable
class AvatarManager {

    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistence

    init(service: RemoteAvatarService, local: LocalAvatarPersistence = MockLocalAvatarPersistence()) {
        self.remote = service
        self.local = local
    }
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try local.addRecentAvatar(avatar: avatar)
        try await remote.incrementAvatarClickCount(avatarId: avatar.id)
    }
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAavatar(avatar: avatar, image: image)
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars()
    }
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars()
    }
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarsForCategory(category: category)
    }
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForAuthor(userId: userId)
    }
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await remote.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    func removeAuthoIdFromAllAvatars(userId: String) async throws {
        try await remote.removeAuthoIdFromAllAvatars(userId: userId)
    }
}
