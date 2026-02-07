//
//  LocalStepsPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

protocol LocalStepsPersistence {
    
    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) throws
    
    // MARK: READ
    func readStepsEntry(id: String) throws -> StepsModel
    func readAllLocalStepsEntries() throws -> [StepsModel]
    
    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) throws
    
    // MARK: DELETE
    func deleteStepsEntry(id: String) throws
    func deleteAllLocalStepsEntries() throws
}
