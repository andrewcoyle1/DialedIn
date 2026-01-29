//
//  MockLocalGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct MockLocalGoalService: LocalGoalService {
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw NSError(domain: "MockGoalError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }
    
    func cacheGoal(_ goal: WeightGoal) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation
    }
    
    func getCachedGoal(id: String, userId: String) async throws -> WeightGoal? {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock returns nil, forcing fetch from remote
        return nil
    }
    
    func getCachedActiveGoal(userId: String) async throws -> WeightGoal? {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock returns nil, forcing fetch from remote
        return nil
    }
    
    func clearCache(userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation
    }
}
