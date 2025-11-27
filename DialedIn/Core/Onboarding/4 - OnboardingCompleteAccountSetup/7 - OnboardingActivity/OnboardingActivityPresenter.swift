//
//  OnboardingActivityPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingActivityPresenter {
    private let interactor: OnboardingActivityInteractor
    private let router: OnboardingActivityRouter

    var selectedActivityLevel: ActivityLevel?
        
    var canSubmit: Bool {
        selectedActivityLevel != nil
    }
    
    init(
        interactor: OnboardingActivityInteractor,
        router: OnboardingActivityRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToCardioFitness(userBuilder: UserModelBuilder) {
        if let activityLevel = selectedActivityLevel {
            var builder = userBuilder
            builder.setActivityLevel(activityLevel)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingCardioFitnessView(delegate: OnboardingCardioFitnessDelegate(userModelBuilder: builder))
        }
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingActivityLevel_Navigate"
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

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    var description: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .light:
            return "Light Activity"
        case .moderate:
            return "Moderate Activity"
        case .active:
            return "Active"
        case .veryActive:
            return "Very Active"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .sedentary:
            return "Desk job, minimal walking, mostly sitting"
        case .light:
            return "Light walking, some daily activities, occasional stairs"
        case .moderate:
            return "Regular walking, standing work, daily movement"
        case .active:
            return "Active lifestyle, frequent movement, manual work"
        case .veryActive:
            return "Highly active, constant movement, physically demanding"
        }
    }
}
