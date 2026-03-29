//
//  AvatarService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

import UIKit
protocol RemoteAvatarService: Sendable {
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws
    func getPopularAvatars() async throws -> [AvatarModel]
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func incrementAvatarClickCount(avatarId: String) async throws
}
