//
//  FirebaseImageUploadService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI
import FirebaseStorage

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}
struct FirebaseImageUploadService: ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: nil)
        }
        _ = try await saveImage(data: data, path: path)
        let url = try await imageReference(forPath: path).downloadURL()
        return url
    }
    private func imageReference(forPath path: String) -> StorageReference {
        let name  = "\(path).jpeg"
        return Storage.storage().reference(withPath: name)
    }
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        let storageRef = self.imageReference(forPath: path)
        let returnedMeta = try await storageRef.putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMeta.path, let url = URL(string: returnedPath) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: nil)
        }
        return url
    }
}
