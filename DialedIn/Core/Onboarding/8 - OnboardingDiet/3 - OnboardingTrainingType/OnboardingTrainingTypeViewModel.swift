//
//  OnboardingTrainingTypeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingTrainingTypeInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingTypeInteractor { }

@MainActor
protocol OnboardingTrainingTypeRouter {
    func showDevSettingsView()
    func showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionViewDelegate)
}

extension CoreRouter: OnboardingTrainingTypeRouter { }

@Observable
@MainActor
class OnboardingTrainingTypeViewModel {
    private let interactor: OnboardingTrainingTypeInteractor
    private let router: OnboardingTrainingTypeRouter

    var selectedTrainingType: TrainingType?
    
    init(
        interactor: OnboardingTrainingTypeInteractor,
        router: OnboardingTrainingTypeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToCalorieDistribution(dietPlanBuilder: DietPlanBuilder) {
        if let trainingType = selectedTrainingType {
            var builder = dietPlanBuilder
            builder.setTrainingType(trainingType)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionViewDelegate(dietPlanBuilder: builder))
        }
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingType_Navigate"
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

enum TrainingType: String, CaseIterable, Identifiable {
    case noneOrRelaxedActivity
    case weightlifting
    case cardio
    case cardioAndWeightlifting
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .noneOrRelaxedActivity:
            return "None or relaxed activity"
        case .weightlifting:
            return "Weightlifting"
        case .cardio:
            return "Cardio"
        case .cardioAndWeightlifting:
            return "Cardio and weightlifting"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .noneOrRelaxedActivity:
            return "No exercise, or light, relaxed activity."
        case .weightlifting:
            return "Strength training, such as weightlifting, bodyweight exercises, or resistance band workouts."
        case .cardio:
            return "Cardiovascular exercise, such as running, cycling, swimming, or brisk walking."
        case .cardioAndWeightlifting:
            return "A combination of cardiovascular and strength training exercises."
        }
    }
}
