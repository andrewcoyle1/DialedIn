//
//  OnboardingCalorieFloorPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCalorieFloorPresenter {
    private let interactor: OnboardingCalorieFloorInteractor
    private let router: OnboardingCalorieFloorRouter

    var selectedFloor: CalorieFloor?
    var trainingDaysPerWeek: Int?
    var hasTrainingPlan: Bool = false

    init(
        interactor: OnboardingCalorieFloorInteractor,
        router: OnboardingCalorieFloorRouter
    ) {
        self.interactor = interactor
        self.router = router
        loadTrainingContext()
    }
    
    private func loadTrainingContext() {
        if let plan = interactor.currentTrainingPlan {
            hasTrainingPlan = true
            // Calculate days per week from first week's scheduled workouts
            if let firstWeek = plan.weeks.first {
                trainingDaysPerWeek = firstWeek.scheduledWorkouts.count
                // Prefill based on training frequency
                prefillCalorieFloor(daysPerWeek: trainingDaysPerWeek ?? 0)
            }
            interactor.trackEvent(event: Event.trainingContextLoaded(daysPerWeek: trainingDaysPerWeek))
        }
    }
    
    private func prefillCalorieFloor(daysPerWeek: Int) {
        // Heuristic: 1-2 days = standard (conservative), 3-4 = standard, 5-6 = standard
        // Since we only have standard and low, default to standard for all
        if selectedFloor == nil {
            selectedFloor = .standard
            interactor.trackEvent(event: Event.calorieFloorPrefilled(floor: .standard, reason: "training_days_\(daysPerWeek)"))
        }
    }
    
    func navigateToTrainingType(dietPlanBuilder: DietPlanBuilder) {
        guard let floor = selectedFloor else { return }
        
        var builder = dietPlanBuilder
        builder.setCalorieFloor(floor)
        
        // Skip TrainingType if training plan exists
        if hasTrainingPlan {
            // Auto-set training type based on plan (default to cardioAndWeightlifting)
            builder.setTrainingType(.cardioAndWeightlifting)
            interactor.trackEvent(event: Event.navigate(
                skipReason: "training_plan_exists"
            ))
            router.showOnboardingCalorieDistributionView(delegate: OnboardingCalorieDistributionDelegate(dietPlanBuilder: builder))
        } else {
            interactor.trackEvent(event: Event.navigate())
            router.showOnboardingTrainingTypeView(delegate: OnboardingTrainingTypeDelegate(dietPlanBuilder: builder))
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    enum Event: LoggableEvent {
        case trainingContextLoaded(daysPerWeek: Int?)
        case calorieFloorPrefilled(floor: CalorieFloor, reason: String)
        case navigate(skipReason: String? = nil)

        var eventName: String {
            switch self {
            case .trainingContextLoaded: return "Onboarding_CalFloor_TrainingContextLoaded"
            case .calorieFloorPrefilled: return "Onboarding_CalFloor_Prefilled"
            case .navigate: return "Onboarding_CalFloor_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .trainingContextLoaded(daysPerWeek: let days):
                return ["daysPerWeek": days as Any]
            case .calorieFloorPrefilled(floor: let floor, reason: let reason):
                return ["floor": floor.rawValue, "reason": reason]
            case .navigate(skipReason: let skipReason):
                var params: [String: Any] = [:]
                if let skipReason = skipReason {
                    params["skipReason"] = skipReason
                }
                return params
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate, .trainingContextLoaded, .calorieFloorPrefilled:
                return .info
            }
        }
    }
}

enum CalorieFloor: String, CaseIterable, Identifiable {
    case standard
    case low
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard:
            return "Standard Floor (Recommended)"
        case .low:
            return "Low Floor"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .standard:
            return "Your recommendations will never go below 1200 calories per day, even if your TDEE is lower."
        case .low:
            return "Your recommendations will never go below 800 calories per day. Proceed with caution."
        }
    }
}
