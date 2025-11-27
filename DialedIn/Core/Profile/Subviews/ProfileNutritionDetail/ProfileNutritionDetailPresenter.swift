//
//  ProfileNutritionDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation

@Observable
@MainActor
class ProfileNutritionDetailPresenter {
    private let interactor: ProfileNutritionDetailInteractor
    private let router: ProfileNutritionDetailRouter

    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }

    init(
        interactor: ProfileNutritionDetailInteractor,
        router: ProfileNutritionDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
