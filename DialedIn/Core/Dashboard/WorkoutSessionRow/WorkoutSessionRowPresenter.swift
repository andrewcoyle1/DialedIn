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
    let reportFlow: ReportFlow
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
        self.reportFlow = ReportFlow(interactor: interactor, router: router)
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

    /// The share button used to raise a "Not implemented yet." alert. There is no deep link for a
    /// session, so there is no URL to share — but the summary the row already displays is worth
    /// sharing on its own, and the view hands this to a `ShareLink`.
    var shareSummary: String {
        let workingSets = session.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }
        // Every row counts towards the volume — both sides were lifted — but a left and a right
        // are one set, so the set count pairs them.
        let volume = workingSets.reduce(0.0) { $0 + (($1.weightKg ?? 0) * Double($1.reps ?? 0)) }
        let setCount = session.exercises.reduce(0) { $0 + $1.workingSetCount }
        var parts = [
            session.name,
            "\(session.exercises.count) exercises",
            "\(setCount) sets"
        ]
        if volume > 0 {
            parts.append("\(Int(volume)) kg lifted")
        }
        return parts.joined(separator: " · ")
    }

    /// The reader cannot report their own workout.
    var canReport: Bool {
        guard let readerId = interactor.currentUser?.userId else { return false }
        return sessionAuthorId != readerId
    }

    func onReportPressed() {
        guard canReport else { return }
        reportFlow.start(ReportedContent(type: .session, id: session.id, authorUserId: sessionAuthorId, noun: "workout"))
    }

    func onUserPressed() {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: author))
    }
}
