//
//  LocalBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol LocalBodyMeasurementService {
    // MARK: CREATE
    func createWeightEntry(weightEntry: BodyMeasurementEntry) throws

    // MARK: READ
    func readWeightEntry(id: String) throws -> BodyMeasurementEntry
    func readWeightEntries() throws -> [BodyMeasurementEntry]

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) throws

    // MARK: DELETE
    func deleteWeightEntry(id: String) throws
}
