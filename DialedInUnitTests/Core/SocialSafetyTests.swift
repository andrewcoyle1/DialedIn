//
//  SocialSafetyTests.swift
//  DialedInUnitTests
//
//  Blocking and reporting across the social surfaces: what a block hides, and what a report sends.
//

import Testing
import SwiftUI
@testable import DialedIn

// MARK: - Comments

/// A blocked person's comments vanish from a thread, and so do the replies under them — which
/// would otherwise surface at the top level as orphans.
@MainActor
struct BlockedCommentsTests {

    private final class Interactor: SpyGlobalInteractor, CommentsInteractor {
        var currentUser: UserModel? = UserModel(userId: "me", blockedUserIds: ["blocked"])
        var fetched: [WorkoutSessionComment] = []
        private(set) var reports: [String] = []

        func fetchComments(sessionId: String) async throws -> [WorkoutSessionComment] { fetched }
        func addComment(_ comment: WorkoutSessionComment) async throws { }
        func deleteComment(id: String) async throws { }

        func report(
            contentType: ReportContentType,
            contentId: String,
            authorUserId: String?,
            reason: ReportReason,
            notes: String?
        ) async throws {
            reports.append("\(contentType.rawValue)|\(contentId)|\(authorUserId ?? "")")
        }
    }

    private final class Router: CommentsRouter {
        let router: AnyRouter = TestRouting.anyRouter
        func showAlert(title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) { }
        func showSimpleAlert(title: String, subtitle: String?) { }
    }

    private func comment(_ id: String, author: String, hour: Int, parentId: String? = nil) -> WorkoutSessionComment {
        WorkoutSessionComment(
            id: id,
            sessionId: "session-x",
            sessionAuthorId: "friend",
            authorId: author,
            authorName: author,
            authorImageUrl: nil,
            text: "Nice work",
            dateCreated: DashboardFixture.date(day: 2, hour: hour),
            parentId: parentId
        )
    }

    @Test("Test A Blocked Authors Comment And Its Replies Are Hidden")
    func testABlockedAuthorsCommentAndItsRepliesAreHidden() async {
        let interactor = Interactor()
        interactor.fetched = [
            comment("kept", author: "friend", hour: 9),
            comment("blocked-root", author: "blocked", hour: 10),
            comment("reply-to-blocked", author: "friend", hour: 11, parentId: "blocked-root"),
            comment("blocked-reply", author: "blocked", hour: 12, parentId: "kept"),
            comment("reply-to-kept", author: "friend", hour: 13, parentId: "kept")
        ]
        let presenter = CommentsPresenter(
            interactor: interactor,
            router: Router(),
            delegate: CommentsDelegate(session: DashboardFixture.session(id: "session-x", author: "friend", on: DashboardFixture.date(day: 2)))
        )

        presenter.onViewAppear()
        await TestManagers.eventually { !presenter.comments.isEmpty }

        #expect(presenter.comments.map(\.id) == ["kept", "reply-to-kept"])
    }
}
