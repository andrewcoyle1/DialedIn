//
//  LocatWorkoutSessionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@MainActor
protocol LocalWorkoutSessionPersistence {
    // Create / Update
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws
    func upsertLocalWorkoutSession(session: WorkoutSessionModel) throws
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws

    // Read
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel
    func getLocalWorkoutSessions(ids: [String]) throws -> [WorkoutSessionModel]
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel]

    // Delete
    func deleteLocalWorkoutSession(id: String) throws
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws

    // Active session persistence
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws
}
