//
//  MockRemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct MockRemoteUserWeightService: RemoteUserWeightService {
    let delay: Double
    let showError: Bool
    
    private var mockEntries: [WeightEntry] = WeightEntry.mocks
    
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
        // In a real implementation, this would persist
    }
    
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        let sorted = mockEntries.sorted { $0.date > $1.date }
        
        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        
        return sorted
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // In a real implementation, this would delete
    }
}
