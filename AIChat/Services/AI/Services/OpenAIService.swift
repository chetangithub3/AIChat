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
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap({$0.toOpenAIModel()})
        let query = ChatQuery(
            messages: messages,
            model: .gpt4_1_nano,
            modalities: [.text],
            maxCompletionTokens: 50
        )
        let result  = try await openAI.chats(query: query)
        guard let chat = result.choices.first?.message, let _ = chat.content?.description else {
            throw OpenAIError.textGenerationFailed
        }
        guard let chatModel = AIChatModel(chat: chat) else {
            throw OpenAIError.textGenerationFailed
        }
        return chatModel
    }
    enum OpenAIError: LocalizedError {
        case imageGenerationFailed
        case textGenerationFailed
    }
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let content: String

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
    init?(chat: ChatResult.Choice.Message) {
        guard let content = chat.content else { return nil }
        role = AIChatRole(rawValue: chat.role)
        self.content = content
    }

    init(role: AIChatRole, content: String) {
        self.role = role
        self.content = content
    }
    func toOpenAIModel() -> ChatQuery.ChatCompletionMessageParam? {
        ChatQuery.ChatCompletionMessageParam(
            role: role.openAIRole,
            content: content
        )
    }
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aiChat_\(CodingKeys.role.rawValue)": role,
            "aiChat_\(CodingKeys.content.rawValue)": content
        ]
        return dict.compactMapValues { $0 }
    }
}

enum AIChatRole: String, Codable {
    case system, user, assistant, tool
    init (rawValue: String) {
        switch rawValue {
            case "system": self = .system
            case "user": self = .user
            case "assistant": self = .assistant
            case "tool": self = .tool
            default: self = .system
        }
    }
    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
            case .system: return .system
            case .user: return .user
            case .assistant: return .assistant
            case .tool: return .tool
        }
    }
}
