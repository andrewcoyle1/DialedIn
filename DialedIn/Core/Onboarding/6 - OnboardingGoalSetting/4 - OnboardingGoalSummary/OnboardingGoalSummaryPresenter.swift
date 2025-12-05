//
//  OnboardingGoalSummaryPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingGoalSummaryPresenter {
    private let interactor: OnboardingGoalSummaryInteractor
    private let router: OnboardingGoalSummaryRouter

    let isStandaloneMode: Bool

    var isLoading: Bool = false
    var goalCreated: Bool = false
    var onDismiss: (() -> Void)?
        
    init(
        interactor: OnboardingGoalSummaryInteractor,
        router: OnboardingGoalSummaryRouter,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.router = router
        self.isStandaloneMode = isStandaloneMode
    }
    
    private func navigateToCustomisingProgram() async {
        try? await interactor.updateOnboardingStep(step: .customiseProgram)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingProgramView()
    }
    
    func uploadGoalSettings(weightGoalBuilder: WeightGoalBuilder) {
        interactor.trackEvent(event: Event.goalSaveStart)
        defer { isLoading = false }

        Task {
            guard let user = interactor.currentUser,
                  let startingWeight = user.weightKilograms else {
                router.showSimpleAlert(
                    title: "Unable to save your Goal",
                    subtitle: "Current weight not available."
                )
                return
            }

            guard let target = weightGoalBuilder.targetWeightKg,
                  let weekly = weightGoalBuilder.weeklyChangeKg else {
                router.showSimpleAlert(
                    title: "Unable to save your Goal",
                    subtitle: "Goal details incomplete."
                )
                return
            }

            do {
                // Create goal in subcollection with frozen starting weight
                let goal = try await interactor.createGoal(userId: user.userId, objective: weightGoalBuilder.objective, startingWeightKg: startingWeight, targetWeightKg: target, weeklyChangeKg: weekly)

                // Update user's currentGoalId reference
                try await interactor.updateCurrentGoalId(goalId: goal.goalId)

                interactor.trackEvent(event: Event.goalSaveSuccess)

                goalCreated = true

                // If standalone mode, auto-dismiss after a brief delay
                if isStandaloneMode {
                    try? await Task.sleep(for: .seconds(0.5))
                    onDismiss?()
                }

                await navigateToCustomisingProgram()
            } catch {
                interactor.trackEvent(event: Event.goalSaveFail(error: error))
                router.showSimpleAlert(
                    title: "Unable to save your Goal",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
        
    // MARK: - Computed Properties
    
    var currentWeight: Double? {
        interactor.currentUser?.weightKilograms
    }
    
    var weightUnit: WeightUnitPreference {
        interactor.currentUser?.weightUnitPreference ?? .kilograms
    }
    
    func weightDifference(targetWeight: Double?) -> Double {
        guard let current = currentWeight else { return 0 }
        guard let target = targetWeight else { return 0 }
        return target - current
    }
    
    func estimatedWeeks(weightGoalBuilder: WeightGoalBuilder) -> Int {
        guard let rate = weightGoalBuilder.weeklyChangeKg, rate > 0 else { return 0 }
        return Int(ceil(abs(weightDifference(targetWeight: weightGoalBuilder.targetWeightKg)) / rate))
    }
    
    func estimatedMonths(weightGoalBuilder: WeightGoalBuilder) -> Int {
        Int(ceil(Double(estimatedWeeks(weightGoalBuilder: weightGoalBuilder)) / 4.33))
    }
    
    func formatWeight(_ weight: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weight)
        case .pounds:
            let pounds = weight * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    func objectiveIcon(objective: OverarchingObjective) -> String {
        let objective = objective.description.lowercased()
        if objective.contains("lose") { return "arrow.down.circle.fill" }
        if objective.contains("maintain") { return "equal.circle.fill" }
        return "arrow.up.circle.fill"
    }
    
    func motivationalMessage(objective: OverarchingObjective) -> String {
        let objective = objective.description.lowercased()
        if objective.contains("lose") {
            return "Every step you take towards your goal is progress. Stay consistent with your nutrition and exercise, and you'll reach your target weight. Remember, sustainable changes lead to lasting results."
        } else if objective.contains("maintain") {
            return "Maintaining your current weight is a fantastic goal! Focus on balanced nutrition and regular activity to keep your body healthy and strong. Consistency is key to long-term success."
        } else {
            return "Building healthy weight takes time and dedication. Focus on nutrient-dense foods and progressive strength training. Your body will thank you for the consistent effort."
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case goalSaveStart
        case goalSaveSuccess
        case goalSaveFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .goalSaveStart:    return "Onboarding_Goal_Save_Start"
            case .goalSaveSuccess:  return "Onboarding_Goal_Save_Success"
            case .goalSaveFail:     return "Onboarding_Goal_Save_Fail"
            case .navigate:         return "Onboarding_Goal_Navigation"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case let .goalSaveFail(error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .goalSaveFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
