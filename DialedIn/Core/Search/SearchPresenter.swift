//
//  SearchPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import SwiftUI

@Observable
@MainActor
class SearchPresenter {

    private let interactor: SearchInteractor
    private let router: SearchRouter

    var searchString: String = ""

    var userImageUrl: String? {
        interactor.userImageUrl
    }

    init(
        interactor: SearchInteractor,
        router: SearchRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onProfilePressed(_ transitionId: String, in namespace: Namespace.ID) {
        router.showProfileViewZoom(
            transitionId: transitionId,
            namespace: namespace
        )
    }

}
