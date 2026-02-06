//
//  MockRemoteBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

class MockRemoteBodyMeasurementService: RemoteBodyMeasurementService {

    let delay: Double
    let showError: Bool
    private var weightEntries: [BodyMeasurementEntry] = []

    init(
        delay: Double,
        showError: Bool,
        weightEntries: [BodyMeasurementEntry] = DialedIn.BodyMeasurementEntry.mocks
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
    func createWeightEntry(entry: BodyMeasurementEntry) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        weightEntries.append(entry)
    }

    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> BodyMeasurementEntry {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()

        return DialedIn.BodyMeasurementEntry.mock
    }

    func readAllWeightEntriesForAuthor(userId: String) async throws -> [BodyMeasurementEntry] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()

        return DialedIn.BodyMeasurementEntry.mocks
    }

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
    }

    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
    }
}
