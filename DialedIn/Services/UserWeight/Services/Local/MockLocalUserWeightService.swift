//
//  MockLocalUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct MockLocalUserWeightService: LocalUserWeightService {
    let delay: Double
    let showError: Bool
    
    init(delay: Double, showError: Bool) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func saveWeightEntry(_ entry: WeightEntry) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation - in production this would use UserDefaults or Core Data
    }
    
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation returns empty, forcing fetch from remote
        return []
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation
    }
    
    func clearCache(userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // Mock implementation
    }
}
