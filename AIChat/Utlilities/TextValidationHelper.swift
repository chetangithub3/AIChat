//
//  TextValidationHelper.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 12/15/25.
//
import Foundation

enum TextValidationError: LocalizedError {
    case notEnoughCharacters(min: Int)
    case hasBadWords
    var errorDescription: String? {
        switch self {
            case .notEnoughCharacters(min: let min):
                "Please add at least \(min) characters"
            case .hasBadWords:
                "No profanity please"
        }
    }
}

struct TextValidationHelper {
    static func validateMessage(for text: String) throws {
        let minimumCharacters: Int = 3
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumCharacters else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacters)
        }
        let badWords: [String] = ["bitch", "ass"]
        if !badWords.contains(where: { text.lowercased().contains($0) }) {
            throw TextValidationError.hasBadWords
        }
    }
}
