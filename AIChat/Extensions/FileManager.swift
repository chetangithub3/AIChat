//
//  FileManager.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/26/26.
//

import Foundation

extension FileManager {
    // MARK: - Save
    static func saveDocument<T: Encodable>(key: String, _ value: T?) throws {

        let url = try documentURL(for: key)
        let data = try JSONEncoder().encode(value)
        try data.write(to: url)
    }
    // MARK: - Get
    static func getDocument<T: Decodable>(
        key: String,
        fileManager: FileManager = .default
    ) throws -> T {
        let url = try documentURL(for: key)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    // MARK: - Helper
    private static func documentURL(for key: String) throws -> URL {
        guard let base = FileManager.default
            .urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        return base.appendingPathComponent("\(key).txt")
    }
}
