//
//  MockRemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

class MockRemoteUserWeightService: RemoteUserWeightService {
    
    let delay: Double
    let showError: Bool
    private var weightEntries: [WeightEntry] = []

    init(
        delay: Double,
        showError: Bool,
        weightEntries: [WeightEntry] = DialedIn.WeightEntry.mocks
    ) {
        self.delay = delay
        self.showError = showError
        self.weightEntries = weightEntries
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    // MARK: CREATE
    func createWeightEntry(entry: WeightEntry) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        weightEntries.append(entry)
    }
    
    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> WeightEntry {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        return DialedIn.WeightEntry.mock
    }
    
    func readAllWeightEntriesForAuthor(userId: String) async throws -> [WeightEntry] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        return DialedIn.WeightEntry.mocks
    }
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
    }
    
    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
    }
}
