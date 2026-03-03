//
//  ExerciseDetailInteractor.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@MainActor
protocol ExerciseDetailInteractor {
    var auth: UserAuthInfo? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
}

extension CoreInteractor: ExerciseDetailInteractor { }
