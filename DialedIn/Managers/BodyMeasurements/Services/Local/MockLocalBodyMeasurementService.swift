//
//  MockLocalBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

final class MockLocalBodyMeasurementService: LocalBodyMeasurementService {
    let delay: Double
    let showError: Bool

    private var weightEntries: [BodyMeasurementEntry] = []

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }

    init(delay: Double, showError: Bool, weightEntries: [BodyMeasurementEntry] = BodyMeasurementEntry.mocks) {
        self.delay = delay
        self.showError = showError
        self.weightEntries = weightEntries
    }

    // MARK: CREATE
    func createWeightEntry(weightEntry: BodyMeasurementEntry) throws {
        try tryShowError()
        // Upsert by id to avoid duplicates when refreshing
        weightEntries.removeAll { $0.id == weightEntry.id }
        weightEntries.append(weightEntry)
    }

    // MARK: READ
    func readWeightEntry(id: String) throws -> BodyMeasurementEntry {
        try tryShowError()
        return BodyMeasurementEntry.mock
    }

    func readWeightEntries() throws -> [BodyMeasurementEntry] {
        try tryShowError()
        return BodyMeasurementEntry.mocks
    }

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) throws {
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
