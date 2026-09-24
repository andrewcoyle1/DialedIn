//
//  CommentsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import SwiftUI

@Observable
@MainActor
class CommentsPresenter {

    private let interactor: CommentsInteractor
    private let router: CommentsRouter
    let session: WorkoutSessionModel

    private(set) var comments: [WorkoutSessionComment] = []
    private(set) var isLoading = false
    private(set) var isSending = false
    var commentDraft: String = ""
    /// The comment the draft replies to, if any. Set by the row's Reply action, cleared by the
    /// bar's cancel or by sending.
    private(set) var replyingTo: WorkoutSessionComment?

    init(
        interactor: CommentsInteractor,
        router: CommentsRouter,
        delegate: CommentsDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.session = delegate.session
    }

    func onViewAppear() {
        Task { await loadComments() }
    }

    private func loadComments() async {
        isLoading = true
        // Sorted here because the query that fetches them has no order clause, so they arrive in
        // document-id order — effectively at random. A reply read before the thing it replies to is
        // nonsense, and new comments are appended to the end, so the thread is oldest first.
        comments = Self.threaded((try? await interactor.fetchComments(sessionId: session.id)) ?? [])
        isLoading = false
    }

    /// Top-level comments oldest first, each followed by its replies oldest first. A reply whose
    /// parent is gone (deleted) is shown at the top level rather than dropped.
    static func threaded(_ comments: [WorkoutSessionComment]) -> [WorkoutSessionComment] {
        let byDate = comments.sorted { $0.dateCreated < $1.dateCreated }
        let ids = Set(byDate.map(\.id))
        let roots = byDate.filter { $0.parentId == nil || !ids.contains($0.parentId ?? "") }
        return roots.flatMap { root in
            [root] + byDate.filter { $0.parentId == root.id }
        }
    }

    func isReply(_ comment: WorkoutSessionComment) -> Bool {
        guard let parentId = comment.parentId else { return false }
        return comments.contains { $0.id == parentId }
    }

    func onReplyPressed(_ comment: WorkoutSessionComment) {
        // Replies stay one level deep: replying to a reply joins its thread.
        replyingTo = comments.first { $0.id == comment.parentId } ?? comment
    }

    func onCancelReplyPressed() {
        replyingTo = nil
    }

    func isOwnComment(_ comment: WorkoutSessionComment) -> Bool {
        comment.authorId == interactor.currentUser?.userId
    }

    func onSendPressed() {
        // Newlines as well as spaces: a draft of nothing but returns is not a comment, and trimming
        // only spaces let it through as a blank row under someone's workout.
        let trimmed = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let user = interactor.currentUser else { return }
        let comment = WorkoutSessionComment(
            id: UUID().uuidString,
            sessionId: session.id,
            sessionAuthorId: session.authorId,
            authorId: user.userId,
            authorName: user.fullNameCalculated,
            authorImageUrl: user.profileImageNameCalculated,
            text: trimmed,
            dateCreated: Date(),
            parentId: replyingTo?.id
        )
        let parent = replyingTo
        commentDraft = ""
        replyingTo = nil
        isSending = true
        Task {
            do {
                try await interactor.addComment(comment)
                comments = Self.threaded(comments + [comment])
            } catch {
                replyingTo = parent
                // Was `try?` followed by an unconditional append: a comment that never reached the
                // server still appeared in the list, and the draft was already cleared, so the text
                // was gone too.
                commentDraft = trimmed
                router.showSimpleAlert(title: "Unable to Post Comment", subtitle: "Please try again.")
            }
            isSending = false
        }
    }

    /// The Report swipe action was a `Button` with an empty closure. `ReportManager` and its remote
    /// service were already built and wired into the container with no caller anywhere in the app;
    /// this is the first one.
    func onReportPressed(_ comment: WorkoutSessionComment) {
        router.showAlert(
            title: "Report Comment",
            subtitle: "Why are you reporting this comment?",
            buttons: {
                AnyView(
                    ForEach(ReportReason.allCases) { reason in
                        Button(reason.displayName) {
                            self.submitReport(comment, reason: reason)
                        }
                    }
                )
            }
        )
    }

    private func submitReport(_ comment: WorkoutSessionComment, reason: ReportReason) {
        Task {
            do {
                try await interactor.report(
                    contentType: .comment,
                    contentId: comment.id,
                    authorUserId: comment.authorId,
                    reason: reason,
                    notes: nil
                )
                router.showSimpleAlert(
                    title: "Report Sent",
                    subtitle: "Thanks — we will take a look at this comment."
                )
            } catch {
                router.showSimpleAlert(
                    title: "Unable to Send Report",
                    subtitle: "Please try again."
                )
            }
        }
    }

    func onDeletePressed(_ comment: WorkoutSessionComment) {
        router.showAlert(title: "Delete Comment?", subtitle: "Are you sure you want to delete your comment? This cannot be undone.", buttons: {
            AnyView(
                Button(role: .destructive) {
                    self.onDeleteConfirmed(comment)
                }
            )
        })
    }
    
    func onDeleteConfirmed(_ comment: WorkoutSessionComment) {
        Task {
            do {
                try await interactor.deleteComment(id: comment.id)
                comments.removeAll { $0.id == comment.id }
            } catch {
                // Was `try?` with an unconditional removal, so a failed delete looked like it worked
                // until the next refresh brought the comment back.
                router.showSimpleAlert(title: "Unable to Delete Comment", subtitle: "Please try again.")
            }
        }
    }
 }

// MARK: - Preview support

extension CommentsPresenter {

    /// Seeds state directly so previews can render states that otherwise only exist mid-flight
    /// (an in-flight send). `private(set)` is file-scoped, so this has to live next to the
    /// presenter rather than in the view file.
    @discardableResult
    func withPreviewState(
        comments: [WorkoutSessionComment]? = nil,
        isLoading: Bool = false,
        isSending: Bool = false,
        draft: String = ""
    ) -> CommentsPresenter {
        if let comments {
            self.comments = comments
        }
        self.isLoading = isLoading
        self.isSending = isSending
        self.commentDraft = draft
        return self
    }
}
