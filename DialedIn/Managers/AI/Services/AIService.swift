//
//  AIService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//
import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}
