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

    private let service: AvatarService

    init(service: AvatarService) {
        self.service = service
    }
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAavatar(avatar: avatar, image: image)
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars()
    }
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars()
    }
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await service.getAvatarsForCategory(category: category)
    }
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await service.getAvatarsForAuthor(userId: userId)
    }
}
