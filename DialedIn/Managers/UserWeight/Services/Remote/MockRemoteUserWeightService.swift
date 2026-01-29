//
//  MockRemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

final class MockRemoteUserWeightService: RemoteUserWeightService {
    let delay: Double
    let showError: Bool
    
    private var entriesByUser: [String: [WeightEntry]] = [:]
    
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
        var list = entriesByUser[entry.userId, default: []]
        list.append(entry)
        entriesByUser[entry.userId] = list
    }
    
    func getWeightHistory(userId: String, limit: Int?) async throws -> [WeightEntry] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        let list = entriesByUser[userId, default: []].sorted { $0.date > $1.date }
        if let limit = limit { return Array(list.prefix(limit)) }
        return list
    }
    
    func deleteWeightEntry(id: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        var list = entriesByUser[userId, default: []]
        list.removeAll { $0.id == id }
        entriesByUser[userId] = list
    }
}
