//
//  RemoteUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol RemoteUserWeightService {
    // MARK: CREATE
    func createWeightEntry(entry: WeightEntry) async throws
    
    // MARK: READ
    func readWeightEntry(userId: String, entryId: String) async throws -> WeightEntry
    func readAllWeightEntriesForAuthor(userId: String) async throws -> [WeightEntry]
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) async throws
    
    // MARK: DELETE
    func deleteWeightEntry(userId: String, entryId: String) async throws

}
