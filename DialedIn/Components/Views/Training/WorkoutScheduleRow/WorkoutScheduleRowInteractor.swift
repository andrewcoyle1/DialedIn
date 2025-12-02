//
//  WorkoutScheduleRowInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutScheduleRowInteractor {
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
}

extension CoreInteractor: WorkoutScheduleRowInteractor { }
