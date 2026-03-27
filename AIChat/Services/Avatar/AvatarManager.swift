//
//  AvatarManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI

protocol AvatarService: Sendable {
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws
}

struct MockAvatarService: AvatarService {
    func createAavatar(avatar: AvatarModel, image: UIImage) async throws {
    }
}
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    
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
}

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
}
