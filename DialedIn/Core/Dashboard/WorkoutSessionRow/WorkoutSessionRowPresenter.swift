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
    
    private(set) var isLiked: Bool = false
    
    init(
        interactor: WorkoutSessionRowInteractor,
        router: WorkoutSessionRowRouter,
        delegate: WorkoutSessionRowDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.session = delegate.session
        self.author = delegate.author
    }
    
    func onWorkoutPressed() {
        router.showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate(workoutSession: session))
    }
    
    func onLikeButtonPressed() {
        self.isLiked.toggle()
    }
    
    func onCommentButtonPressed() {
        
    }
    
    func onShareButtonPressed() {
        
    }
    
    func onUserPressed() {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: author))
    }
}
