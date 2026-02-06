//
//  RemoteBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol RemoteBodyMeasurementService {
    // MARK: CREATE
    func createWeightEntry(entry: BodyMeasurementEntry) async throws

    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> BodyMeasurementEntry
    func readAllWeightEntriesForAuthor(userId: String) async throws -> [BodyMeasurementEntry]

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws

    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws
}
