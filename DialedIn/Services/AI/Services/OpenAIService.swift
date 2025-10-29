//
//  OpenAIService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//
@preconcurrency import OpenAI
import SwiftUI

private typealias ChatCompletion = ChatQuery.ChatCompletionMessageParam
private typealias SystemMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionSystemMessageParam
private typealias UserMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam
private typealias UserTextContent = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content
private typealias AssistantMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionAssistantMessageParam

struct OpenAIService: AIService {
    
    private let client: OpenAI = OpenAI(apiToken: Keys.openAI)
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            n: 1,
//            quality: .hd,
            responseFormat: .b64_json,
            size: ._1024,
//            style: .natural,
            user: nil
        )
        
        let result = try await client.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap({ $0.toOpenAIModel() })
        let query = ChatQuery(messages: messages, model: .gpt3_5Turbo)
        let result = try await client.chats(query: query)
        
        guard
            let chat = result.choices.first?.message,
            let model = AIChatModel(chat: chat)
        else {
            throw OpenAIError.invalidResponse
        }
        
        return model
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}

// MARK: - OpenAI-Specific Extensions

extension AIChatModel {
    init?(chat: ChatResult.Choice.ChatCompletionMessage) {
        self.role = AIChatRole(role: chat.role)
        
        if let string = chat.content?.string {
            self.message = string
        } else {
            return nil
        }
    }
    
    fileprivate func toOpenAIModel() -> ChatCompletion? {
        switch role {
        case .system:
            return ChatCompletion.system(SystemMessage(content: message))
        case .user:
            return ChatCompletion.user(UserMessage(content: UserTextContent(string: message)))
        case .assistant:
            return ChatCompletion.assistant(AssistantMessage(content: message))
        case .tool:
            return nil
        }
    }
}

extension AIChatRole {
    init(role: ChatQuery.ChatCompletionMessageParam.Role) {
        switch role {
        case .system:
            self = .system
        case .user:
            self = .user
        case .assistant:
            self = .assistant
        case .tool:
            self = .tool
        }
    }
    
    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .system:
            return .system
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .tool:
            return .tool
        }
    }
}
