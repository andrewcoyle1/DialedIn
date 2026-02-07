//
//  MuscleGroupDetailInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol MuscleGroupDetailInteractor {
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
}

extension CoreInteractor: MuscleGroupDetailInteractor { }
