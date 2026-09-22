//
//  CommentsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

@MainActor
protocol CommentsInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func fetchComments(sessionId: String) async throws -> [WorkoutSessionComment]
    func addComment(_ comment: WorkoutSessionComment) async throws
    func deleteComment(id: String) async throws
    func report(contentType: ReportContentType, contentId: String, authorUserId: String?, reason: ReportReason, notes: String?) async throws
}

extension CoreInteractor: CommentsInteractor { }
