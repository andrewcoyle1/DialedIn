//
//  OnboardingPreferredDietViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingPreferredDietInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingPreferredDietInteractor { }

@MainActor
protocol OnboardingPreferredDietRouter {
    func showDevSettingsView()
    func showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorViewDelegate)
}

extension CoreRouter: OnboardingPreferredDietRouter { }

@Observable
@MainActor
class OnboardingPreferredDietViewModel {
    private let interactor: OnboardingPreferredDietInteractor
    private let router: OnboardingPreferredDietRouter

    var selectedDiet: PreferredDiet?
        
    init(
        interactor: OnboardingPreferredDietInteractor,
        router: OnboardingPreferredDietRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToCalorieFloor() {
        if let diet = selectedDiet {
            let dietPlanBuilder = DietPlanBuilder(preferredDiet: diet)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingCalorieFloorView(delegate: OnboardingCalorieFloorViewDelegate(dietPlanBuilder: dietPlanBuilder))
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_PrefDiet_Navigate"
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

enum PreferredDiet: String, CaseIterable, Identifiable {
    case balanced
    case lowFat
    case lowCarb
    case keto

    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .balanced:
            return "Balanced"
        case .lowFat:
            return "Low Fat"
        case .lowCarb:
            return "Low Carb"
        case .keto:
            return "Keto"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .balanced:
            return "Standard distribution of carbs and fat."
        case .lowFat:
            return "Fat will be reduced to prioritize carb and protein intake."
        case .lowCarb:
            return "Carbs will be reduced to prioritize fat and protein intake."
        case .keto:
            return "Carbs will be very restricted to allow for higher fat intake."
        }
    }
}
