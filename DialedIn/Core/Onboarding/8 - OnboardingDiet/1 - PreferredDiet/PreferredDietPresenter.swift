//
//  PreferredDietPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class PreferredDietPresenter {
    private let interactor: PreferredDietInteractor
    private let router: PreferredDietRouter

    var selectedDiet: PreferredDiet?
    private var isFromSettings: Bool = false

    init(
        interactor: PreferredDietInteractor,
        router: PreferredDietRouter,
        isFromSettings: Bool = false
    ) {
        self.interactor = interactor
        self.router = router
        self.isFromSettings = isFromSettings
    }

    func navigateToCalorieFloor() {
        if let diet = selectedDiet {
            let delegate = CalorieFloorDelegate(preferredDiet: diet, isFromSettings: isFromSettings)
            interactor.trackEvent(event: Event.navigate)
            router.showCalorieFloorView(delegate: delegate)
        }
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

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
