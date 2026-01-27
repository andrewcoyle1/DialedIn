//
//  SearchPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/01/2026.
//

import Foundation

@Observable
@MainActor
class SearchPresenter {

    private let interactor: SearchInteractor
    private let router: SearchRouter

    var searchString: String = ""

    init(
        interactor: SearchInteractor,
        router: SearchRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
}
