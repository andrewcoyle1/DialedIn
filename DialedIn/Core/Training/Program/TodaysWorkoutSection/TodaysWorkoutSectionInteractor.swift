//
//  TodaysWorkoutSectionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

protocol TodaysWorkoutSectionInteractor {
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel

    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: TodaysWorkoutSectionInteractor { }
