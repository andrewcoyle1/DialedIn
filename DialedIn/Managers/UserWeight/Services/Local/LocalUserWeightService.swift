//
//  LocalUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol LocalUserWeightService {
    // MARK: CREATE
    func createWeightEntry(weightEntry: WeightEntry) throws
    
    // MARK: READ
    func readWeightEntry(id: String) throws -> WeightEntry
    func readWeightEntries() throws -> [WeightEntry]
    
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) throws
    
    // MARK: DELETE
    func deleteWeightEntry(id: String) throws
    
}
