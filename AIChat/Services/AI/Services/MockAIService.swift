//
//  MockAIService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI
struct MockAIService: AIService {
    let delay: Double
    let doesThrow: Bool

    init(delay: Double = 1, doesThrow: Bool = false) {
        self.delay = delay
        self.doesThrow = doesThrow
    }
    func throwError() throws {
        if doesThrow {
            throw URLError(.unknown)
        }
    }
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(delay))
        guard let chat =  chats.first else { throw URLError.init(.unknown)}
        try throwError()
        return chat
    }
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(delay))
        try throwError()
        return UIImage(systemName: "star.fill")!
    }
}
