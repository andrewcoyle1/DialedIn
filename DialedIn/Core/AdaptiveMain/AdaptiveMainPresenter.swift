//
//  AdaptiveMainPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/10/2025.
//

import Foundation

@Observable
@MainActor
class AdaptiveMainPresenter {
    private let interactor: AdaptiveMainInteractor
    private let router: AdaptiveMainRouter

    init(
        interactor: AdaptiveMainInteractor,
        router: AdaptiveMainRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func getActiveLocalWorkoutSession() {
        _ = try? interactor.getActiveLocalWorkoutSession()
    }

}
