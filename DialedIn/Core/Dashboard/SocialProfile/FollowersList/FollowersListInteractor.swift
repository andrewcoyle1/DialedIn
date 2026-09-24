//
//  FollowersListInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

@MainActor
protocol FollowersListInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func followUser(userId: String) async throws
    func unfollowUser(userId: String) async throws
}

extension CoreInteractor: FollowersListInteractor { }
