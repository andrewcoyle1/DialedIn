//
//  WorkoutSummaryCardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutSummaryCardInteractor {
    func trackEvent(event: LoggableEvent)
    func getWorkoutSessionWithFallback(id: String) async throws -> WorkoutSessionModel
}

extension CoreInteractor: WorkoutSummaryCardInteractor { }
