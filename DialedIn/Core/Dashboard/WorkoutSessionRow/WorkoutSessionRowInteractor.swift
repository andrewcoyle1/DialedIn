//
//  WorkoutSessionRowInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/02/2026.
//

@MainActor
protocol WorkoutSessionRowInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func likeSession(sessionId: String, authorId: String, userId: String) async throws
    func unlikeSession(sessionId: String, authorId: String, userId: String) async throws
}

extension CoreInteractor: WorkoutSessionRowInteractor { }
