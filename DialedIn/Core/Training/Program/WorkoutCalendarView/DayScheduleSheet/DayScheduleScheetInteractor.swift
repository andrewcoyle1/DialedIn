//
//  DayScheduleScheetInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DayScheduleScheetInteractor {
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
}

extension CoreInteractor: DayScheduleScheetInteractor { }
