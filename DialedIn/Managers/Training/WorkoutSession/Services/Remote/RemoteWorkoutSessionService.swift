//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//
import Foundation

protocol RemoteWorkoutSessionService {
    // Create / Update
    func createWorkoutSession(session: WorkoutSessionModel) async throws
    func updateWorkoutSession(session: WorkoutSessionModel) async throws
    func endWorkoutSession(id: String, at endedAt: Date) async throws

    // Read
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
    func getWorkoutSessions(ids: [String], limitTo: Int) async throws -> [WorkoutSessionModel]
    func getWorkoutSessionsByTemplateAndAuthor(templateId: String, authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel]
    func getWorkoutSessionsForAuthor(authorId: String, limitTo: Int) async throws -> [WorkoutSessionModel]
    func getLastCompletedSessionForTemplate(templateId: String, authorId: String) async throws -> WorkoutSessionModel?

    // Delete
    func deleteWorkoutSession(id: String) async throws
    func deleteAllWorkoutSessionsForAuthor(authorId: String) async throws
}
