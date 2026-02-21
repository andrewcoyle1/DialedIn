//
//  AIManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//
import SwiftUI

@Observable
@MainActor
class AIManager {
    
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await service.generateText(chats: chats)
    }
}
