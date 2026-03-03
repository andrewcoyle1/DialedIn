//
//  WorkoutHistoryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol WorkoutHistoryInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
}

extension CoreInteractor: WorkoutHistoryInteractor { }
