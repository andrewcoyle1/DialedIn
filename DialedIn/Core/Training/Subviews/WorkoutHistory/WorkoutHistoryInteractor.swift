//
//  WorkoutHistoryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol WorkoutHistoryInteractor: GlobalInteractor {
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int) async throws
}

extension CoreInteractor: WorkoutHistoryInteractor { }
