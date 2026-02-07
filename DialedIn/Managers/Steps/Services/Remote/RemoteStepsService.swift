//
//  RemoteStepsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

protocol RemoteStepsService {
    
    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) async throws
    
    // MARK: READ
    func readStepsEntry(userId: String, stepsId: String) async throws -> StepsModel
    func readAllStepsEntriesForAuthor(userId: String) async throws -> [StepsModel]
    
    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) async throws
    
    // MARK: DELETE
    func deleteStepsEntry(userId: String, stepsId: String) async throws

}
