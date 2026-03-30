//
//  AIService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}
