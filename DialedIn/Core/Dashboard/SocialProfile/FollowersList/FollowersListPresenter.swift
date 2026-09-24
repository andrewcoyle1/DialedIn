//
//  FollowersListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

import Foundation

@Observable
@MainActor
class FollowersListPresenter {
    private let interactor: FollowersListInteractor
    private let router: FollowersListRouter
    private let followFlow: FollowFlow

    init(interactor: FollowersListInteractor, router: FollowersListRouter) {
        self.interactor = interactor
        self.router = router
        self.followFlow = FollowFlow(interactor: interactor, router: router)
    }

    /// The reader's own row carries no follow button.
    func showsFollowButton(for user: UserModel) -> Bool {
        user.userId != interactor.currentUser?.userId
    }

    func followState(for user: UserModel) -> FollowState {
        followFlow.state(for: user)
    }

    func onFollowButtonPressed(user: UserModel) {
        followFlow.onButtonPressed(user: user)
    }

    func onUserPressed(user: UserModel) {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: user))
    }
}
