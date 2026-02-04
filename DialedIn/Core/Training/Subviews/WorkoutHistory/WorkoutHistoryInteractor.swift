//
//  WorkoutHistoryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol WorkoutHistoryInteractor {
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func syncWorkoutSessionsFromRemote(authorId: String, limitTo: Int) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WorkoutHistoryInteractor { }
