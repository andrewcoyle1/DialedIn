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
    
    init(interactor: FollowersListInteractor, router: FollowersListRouter) {
        self.interactor = interactor
        self.router = router
    }

    /// The reader's own row carries no follow button.
    func showsFollowButton(for user: UserModel) -> Bool {
        user.userId != interactor.currentUser?.userId
    }

    func isFollowing(userId: String) -> Bool {
        interactor.currentUser?.followingIds?.contains(userId) ?? false
    }

    func onFollowPressed(user: UserModel) {
        Task {
            do {
                try await interactor.followUser(userId: user.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to follow user", subtitle: "Please try again.")
            }
        }
    }

    func onUnfollowPressed(user: UserModel) {
        Task {
            do {
                try await interactor.unfollowUser(userId: user.userId)
            } catch {
                router.showSimpleAlert(title: "Unable to unfollow user", subtitle: "Please try again.")
            }
        }
    }

    func onUserPressed(user: UserModel) {
        router.showSocialProfileView(delegate: SocialProfileDelegate(user: user))
    }
}
