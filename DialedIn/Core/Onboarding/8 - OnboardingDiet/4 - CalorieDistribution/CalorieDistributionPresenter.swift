//
//  CalorieDistributionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class CalorieDistributionPresenter {
    private let interactor: CalorieDistributionInteractor
    private let router: CalorieDistributionRouter

    var selectedCalorieDistribution: CalorieDistribution?
    var trainingDaysPerWeek: Int?
    var hasTrainingPlan: Bool = false
    
    init(
        interactor: CalorieDistributionInteractor,
        router: CalorieDistributionRouter
    ) {
        self.interactor = interactor
        self.router = router
        loadTrainingContext()
    }
    
    private func loadTrainingContext() {
//        if let plan = interactor.currentTrainingPlan {
//            hasTrainingPlan = true
//            // Calculate days per week from first week's scheduled workouts
//            if let firstWeek = plan.weeks.first {
//                trainingDaysPerWeek = firstWeek.scheduledWorkouts.count
//                // Prefill based on training frequency
//                prefillCalorieDistribution(daysPerWeek: trainingDaysPerWeek ?? 0)
//            }
//            interactor.trackEvent(event: Event.trainingContextLoaded(daysPerWeek: trainingDaysPerWeek))
//        }
    }
    
    private func prefillCalorieDistribution(daysPerWeek: Int) {
        // Heuristic: <=3 days = even, >=4 days = varied (to bias carbs to training days)
        if selectedCalorieDistribution == nil {
            if daysPerWeek <= 3 {
                selectedCalorieDistribution = .even
            } else {
                selectedCalorieDistribution = .varied
            }
            interactor.trackEvent(event: Event.calorieDistributionPrefilled(
                distribution: selectedCalorieDistribution ?? .even,
                reason: "training_days_\(daysPerWeek)"
            ))
        }
    }
    
    func navigateToProteinIntake(delegate: CalorieDistributionDelegate) {
        if let calorieDistribution = selectedCalorieDistribution {
            interactor.trackEvent(event: Event.navigate)
            router.showProteinIntakeView(delegate: ProteinIntakeDelegate(delegate: delegate, calorieDistribution: calorieDistribution))
        }
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    enum Event: LoggableEvent {
        case trainingContextLoaded(daysPerWeek: Int?)
        case calorieDistributionPrefilled(distribution: CalorieDistribution, reason: String)
        case navigate

        var eventName: String {
            switch self {
            case .trainingContextLoaded: return "Onboarding_CalDist_TrainingContextLoaded"
            case .calorieDistributionPrefilled: return "Onboarding_CalDist_Prefilled"
            case .navigate: return "Onboarding_CalDist_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .trainingContextLoaded(daysPerWeek: let days):
                return ["daysPerWeek": days as Any]
            case .calorieDistributionPrefilled(distribution: let dist, reason: let reason):
                return ["distribution": dist.rawValue, "reason": reason]
            case .navigate:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate, .trainingContextLoaded, .calorieDistributionPrefilled:
                return .info
            }
        }
    }
}

enum CalorieDistribution: String, CaseIterable, Identifiable {
    case even
    case varied
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .even:
            return "Distribute Evenly"
        case .varied:
            return "Vary By Day"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .even:
            return "Distribute calories evenly across all days of the week."
        case .varied:
            return "Distribute calories to increase energy on training days."
        }
    }
}
