//
//  OnboardingProteinIntakePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingProteinIntakePresenter {
    private let interactor: OnboardingProteinIntakeInteractor
    private let router: OnboardingProteinIntakeRouter

    var selectedProteinIntake: ProteinIntake?
    var hasTrainingPlan: Bool = false

    init(
        interactor: OnboardingProteinIntakeInteractor,
        router: OnboardingProteinIntakeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigate(dietPlanBuilder: DietPlanBuilder) {
        if let proteinIntake = selectedProteinIntake {
            var builder = dietPlanBuilder
            builder.setProteinIntake(proteinIntake)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingDietPlanView(delegate: OnboardingDietPlanDelegate(dietPlanBuilder: builder))
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case proteinIntakePrefilled(intake: ProteinIntake, reason: String)
        case navigate

        var eventName: String {
            switch self {
            case .proteinIntakePrefilled: return "Onboarding_ProteinIntake_Prefilled"
            case .navigate: return "Onboarding_ProteinIntake_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .proteinIntakePrefilled(intake: let intake, reason: let reason):
                return ["intake": intake.rawValue, "reason": reason]
            case .navigate:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate, .proteinIntakePrefilled:
                return .info
            }
        }
    }
}

enum ProteinIntake: String, CaseIterable, Identifiable {
    case low
    case moderate
    case high
    case veryHigh
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        case .veryHigh:
            return "Very High"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .low:
            return "On the low side of the optimal range."
        case .moderate:
            return "In the middle of the optimal range."
        case .high:
            return "On the high end of the optimal range."
        case .veryHigh:
            return "Highest recommended intake."
        }
    }
}
