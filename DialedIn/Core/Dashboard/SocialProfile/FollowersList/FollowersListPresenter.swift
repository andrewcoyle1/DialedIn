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
}
