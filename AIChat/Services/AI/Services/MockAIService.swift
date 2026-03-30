//
//  MockAIService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI
struct MockAIService: AIService {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        guard let chat =  chats.first else { throw URLError.init(.unknown)}
        return chat
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "star.fill")!
    }
}
