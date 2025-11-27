//
//  ProfileNutritionPlanPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileNutritionPlanPresenter {
    private let interactor: ProfileNutritionPlanInteractor
    private let router: ProfileNutritionPlanRouter

    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(
        interactor: ProfileNutritionPlanInteractor,
        router: ProfileNutritionPlanRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func navToNutritionDetail() {
        interactor.trackEvent(event: Event.navigate)
        router.showProfileNutritionDetailView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
