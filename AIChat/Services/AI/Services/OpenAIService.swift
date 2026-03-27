//
//  OpenAIService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI
import OpenAI

struct OpenAIService: AIService {
    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAIAPIKey)
    }

    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .gpt_image_1,
            n: 1,
            size: .auto,
            user: nil
        )

        let result = try await openAI.images(query: query)
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data)
        else {
            throw OpenAIError.imageGenerationFailed
        }
        return image
    }
    enum OpenAIError: LocalizedError {
        case imageGenerationFailed
    }
}
