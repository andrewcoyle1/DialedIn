//
//  TodaysWorkoutCardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol TodaysWorkoutCardInteractor {
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: TodaysWorkoutCardInteractor { }
