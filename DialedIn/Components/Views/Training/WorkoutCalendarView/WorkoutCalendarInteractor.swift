//
//  WorkoutCalendarInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutCalendarInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func trackEvent(event: LoggableEvent)
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
}

extension CoreInteractor: WorkoutCalendarInteractor { }
