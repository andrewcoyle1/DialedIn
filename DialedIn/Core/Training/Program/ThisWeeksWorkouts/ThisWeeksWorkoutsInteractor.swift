//
//  ThisWeeksWorkoutsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

protocol ThisWeeksWorkoutsInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel

    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ThisWeeksWorkoutsInteractor { }
