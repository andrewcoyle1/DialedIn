//
//  WorkoutSessionRowPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/02/2026.
//

import Foundation

@Observable
@MainActor
class WorkoutSessionRowPresenter {

    private let interactor: WorkoutSessionRowInteractor
    private let router: WorkoutSessionRowRouter
    let session: WorkoutSessionModel
    let author: UserModel
    private let sessionAuthorId: String

    private(set) var isLiked: Bool
    private(set) var likeCount: Int

    init(
        interactor: WorkoutSessionRowInteractor,
        router: WorkoutSessionRowRouter,
        delegate: WorkoutSessionRowDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.session = delegate.session
        self.author = delegate.author
        self.sessionAuthorId = delegate.session.authorId
        self.isLiked = delegate.session.likedByUserIds.contains(interactor.currentUser?.userId ?? "")
        self.likeCount = delegate.session.likedByUserIds.count
    }

    func onWorkoutPressed() {
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
    }

    func onLikeButtonPressed() {
        guard let userId = interactor.currentUser?.userId else { return }
        let wasLiked = isLiked
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        Task {
            do {
                if isLiked {
                    try await interactor.likeSession(sessionId: session.id, authorId: sessionAuthorId, userId: userId)
                } else {
                    try await interactor.unlikeSession(sessionId: session.id, authorId: sessionAuthorId, userId: userId)
                }
            } catch {
                isLiked = wasLiked
                likeCount += wasLiked ? 1 : -1
            }
        }
    }

    func onCommentButtonPressed() {
        router.showCommentsView(delegate: CommentsDelegate(session: session))
    }

    func onShareButtonPressed() {
        router.showSimpleAlert(title: "Share", subtitle: "Not implemented yet.")
    }

    func onUserPressed() {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: author))
    }
}
