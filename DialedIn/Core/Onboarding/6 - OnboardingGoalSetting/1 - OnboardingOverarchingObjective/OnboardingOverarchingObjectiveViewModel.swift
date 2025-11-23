//
//  OnboardingOverarchingObjectiveViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingOverarchingObjectiveInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingOverarchingObjectiveInteractor { }

@MainActor
protocol OnboardingOverarchingObjectiveRouter {
    func showDevSettingsView()
    func showOnboardingTargetWeightView(delegate: OnboardingTargetWeightViewDelegate)
    func showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryViewDelegate)
}

extension CoreRouter: OnboardingOverarchingObjectiveRouter { }

@Observable
@MainActor
class OnboardingOverarchingObjectiveViewModel {
    private let interactor: OnboardingOverarchingObjectiveInteractor
    private let router: OnboardingOverarchingObjectiveRouter

    let isStandaloneMode: Bool
    
    var selectedObjective: OverarchingObjective?
        
    var userWeight: Double? {
        interactor.currentUser?.weightKilograms
    }
    
    var canContinue: Bool { selectedObjective != nil && userWeight != nil }
    
    init(
        interactor: OnboardingOverarchingObjectiveInteractor,
        router: OnboardingOverarchingObjectiveRouter,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.router = router
        self.isStandaloneMode = isStandaloneMode
    }
    
    func navigateToNextStep() {
        guard let objective = selectedObjective else { return }
        if objective == .maintain {
            let weightGoalBuilder = WeightGoalBuilder(objective: objective, targetWeightKg: 0, weeklyChangeKg: 0)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingGoalSummaryView(delegate: OnboardingGoalSummaryViewDelegate(weightGoalBuilder: weightGoalBuilder))
        } else {
            let weightGoalBuilder = WeightGoalBuilder(objective: objective)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingTargetWeightView(delegate: OnboardingTargetWeightViewDelegate(weightGoalBuilder: weightGoalBuilder))
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OverarchingObjecting_Navigate"
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
            case .navigate: return .info
            }
        }
    }
}

enum OverarchingObjective: Codable, CaseIterable {
    case loseWeight
    case maintain
    case gainWeight
    
    var description: String {
        switch self {
        case .loseWeight:
            "Lose weight"
        case .maintain:
            "Maintain"
        case .gainWeight:
            "Gain weight"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .loseWeight:
            "Goal of losing weight"
        case .maintain:
            "Goal of maintaining weight"
        case .gainWeight:
            "Goal of gaining weight"
        }
    }
}
