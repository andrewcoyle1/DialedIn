//
//  OnboardingPreferredDietViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingPreferredDietInteractor {
    func setPreferredDiet(_ value: PreferredDiet)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingPreferredDietInteractor { }

@Observable
@MainActor
class OnboardingPreferredDietViewModel {
    private let interactor: OnboardingPreferredDietInteractor
    
    var selectedDiet: PreferredDiet?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingPreferredDietInteractor) {
        self.interactor = interactor
    }
    
    func navigateToCalorieFloor(path: Binding<[OnboardingPathOption]>) {
        if let diet = selectedDiet {
            interactor.setPreferredDiet(diet)
            interactor.trackEvent(event: Event.navigate(destination: .calorieFloor))
            path.wrappedValue.append(.calorieFloor)
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_PrefDiet_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
