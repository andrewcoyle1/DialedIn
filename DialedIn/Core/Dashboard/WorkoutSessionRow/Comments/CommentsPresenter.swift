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
        comments = (try? await interactor.fetchComments(sessionId: session.id)) ?? []
        isLoading = false
    }

    func isOwnComment(_ comment: WorkoutSessionComment) -> Bool {
        comment.authorId == interactor.currentUser?.userId
    }

    func onSendPressed() {
        let trimmed = commentDraft.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let user = interactor.currentUser else { return }
        let comment = WorkoutSessionComment(
            id: UUID().uuidString,
            sessionId: session.id,
            sessionAuthorId: session.authorId,
            authorId: user.userId,
            authorName: user.fullNameCalculated,
            authorImageUrl: user.profileImageNameCalculated,
            text: trimmed,
            dateCreated: Date()
        )
        commentDraft = ""
        isSending = true
        Task {
            try? await interactor.addComment(comment)
            comments.append(comment)
            isSending = false
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
            try? await interactor.deleteComment(id: comment.id)
            comments.removeAll { $0.id == comment.id }
        }
    }
 }
