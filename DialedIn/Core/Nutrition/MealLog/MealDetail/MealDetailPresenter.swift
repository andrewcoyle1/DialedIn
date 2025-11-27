//
//  MealDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

@Observable
@MainActor
class MealDetailPresenter {
    private let interactor: MealDetailInteractor
    private let router: MealDetailRouter

    init(
        interactor: MealDetailInteractor,
        router: MealDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
