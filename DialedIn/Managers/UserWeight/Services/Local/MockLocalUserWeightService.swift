//
//  MockLocalUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

final class MockLocalUserWeightService: LocalUserWeightService {
    let delay: Double
    let showError: Bool
    
    private var weightEntries: [WeightEntry] = []

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    init(delay: Double, showError: Bool, weightEntries: [WeightEntry] = WeightEntry.mocks) {
        self.delay = delay
        self.showError = showError
        self.weightEntries = weightEntries
    }
    
    // MARK: CREATE
    func createWeightEntry(weightEntry: WeightEntry) throws {
        try tryShowError()
        // Upsert by id to avoid duplicates when refreshing
        weightEntries.removeAll { $0.id == weightEntry.id }
        weightEntries.append(weightEntry)
    }
    
    // MARK: READ
    func readWeightEntry(id: String) throws -> WeightEntry {
        try tryShowError()
        return WeightEntry.mock
    }
    
    func readWeightEntries() throws -> [WeightEntry] {
        try tryShowError()
        return WeightEntry.mocks
    }
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) throws {
        try tryShowError()
        weightEntries.removeAll { $0.id == entry.id }
        weightEntries.append(entry)
    }
    
    // MARK: DELETE
    func deleteWeightEntry(id: String) throws {
        try tryShowError()
        weightEntries.removeAll { $0.id == id }
    }
}
