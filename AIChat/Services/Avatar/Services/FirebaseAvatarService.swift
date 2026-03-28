//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 100)
            .getAllDocuments()
            .shuffled()
            .first(upto: 5) ?? []
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 10)
            .getAllDocuments()
            .shuffled()
            .first(upto: 5) ?? []
    }
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
        let path: String = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        var avatar = avatar
        avatar.updateImage(imageName: url.absoluteString)
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.avatarId.rawValue, isEqualTo: category.rawValue)
            .limit(to: 10)
            .getAllDocuments()
    }
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
}
