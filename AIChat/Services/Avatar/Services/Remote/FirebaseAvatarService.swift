//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/28/26.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    func getPopularAvatars() async throws -> [AvatarModel] {
        let list: [AvatarModel] = try await collection
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 100)
            .getAllDocuments()
        return list.first(upto: 5) ?? []
    }
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 10)
            .getAllDocuments()
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
            .whereField(AvatarModel.CodingKeys.characterOption .rawValue, isEqualTo: category.rawValue)
            .limit(to: 10)
            .getAllDocuments()
    }
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
}
