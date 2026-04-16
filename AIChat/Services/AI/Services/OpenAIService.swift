//
//  OpenAIService.swift
//  AIChat
//
//  Created by Chetan Dhowlaghar on 3/27/26.
//

import SwiftUI
import FirebaseFunctions

struct OpenAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        let result = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])
        guard let b64Json = result.data as? String,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data)
        else {
            throw OpenAIError.imageGenerationFailed
        }
        return image
    }
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { chat in
            let role = chat.role.rawValue
            let content = chat.content
            return [
                "role": role,
                "content": content
            ]
        }
        let response = try await Functions.functions().httpsCallable("generateOpenAIText").call([
            "messages": messages
        ])
        guard let dict = response.data as? [String: Any],
                let roleString = dict["role"] as? String,
                let content = dict["content"] as? String else {
                throw OpenAIError.textGenerationFailed
              }
        let res = AIChatModel(role: AIChatRole(rawValue: roleString), content: content)
        dump(res, name: "sssssss")
        return res
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
    init(role: AIChatRole, content: String) {
        self.role = role
        self.content = content
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
}
