//
//  ProfileNutritionDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation

protocol ProfileNutritionDetailInteractor {
    var currentDietPlan: DietPlan? { get }
}

extension CoreInteractor: ProfileNutritionDetailInteractor { }

@MainActor
protocol ProfileNutritionDetailRouter {
    func showDevSettingsView()
}

extension CoreRouter: ProfileNutritionDetailRouter { }

@Observable
@MainActor
class ProfileNutritionDetailViewModel {
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
