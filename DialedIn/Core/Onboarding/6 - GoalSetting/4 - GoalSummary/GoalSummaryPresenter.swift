//
//  GoalSummaryPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class GoalSummaryPresenter {
    private let interactor: GoalSummaryInteractor
    private let router: GoalSummaryRouter

    let isStandaloneMode: Bool

    var isLoading: Bool = false
    var goalCreated: Bool = false
    var onDismiss: (() -> Void)?
        
    init(
        interactor: GoalSummaryInteractor,
        router: GoalSummaryRouter,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.router = router
        self.isStandaloneMode = isStandaloneMode
    }
    
    func onCompletePressed(delegate: GoalSummaryDelegate) {
        onContinuePressed(delegate: delegate)
        onDismiss?()
    }
    
    func onContinuePressed(delegate: GoalSummaryDelegate) {
        interactor.trackEvent(event: Event.goalSaveStart)
        defer { isLoading = false }

        Task {
            guard let user = interactor.currentUser,
                  let startingWeight = user.submittedWeightKilograms else {
                router.showSimpleAlert(
                    title: "Unable to save your Goal",
                    subtitle: "Current weight not available."
                )
                return
            }

            do {
                // Create goal in subcollection with frozen starting weight
                let goal = try await interactor.createGoal(userId: user.userId, objective: delegate.overarchingObjective, startingWeightKg: startingWeight, targetWeightKg: delegate.targetWeight, weeklyChangeKg: delegate.weightChangeRate)

                // Update user's currentGoalId reference
                try await interactor.updateCurrentGoalId(goalId: goal.goalId)

                interactor.trackEvent(event: Event.goalSaveSuccess)

                handleNavigation()
            } catch {
                interactor.trackEvent(event: Event.goalSaveFail(error: error))
                router.showSimpleAlert(
                    title: "Unable to save your Goal",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    // MARK: Handle Navigation
    func handleNavigation() {
        // Navigate based on user's inferred onboarding step
        if let currentUser = interactor.currentUser {
            let step = currentUser.inferredOnboardingStep
            interactor.trackEvent(event: Event.navigate)
            route(to: step)
        }
    }

    private func route(to step: OnboardingStep) {
        switch step {
        case .auth, .subscription:
            // For anything at/before subscription, move them into complete-account setup
            router.showCompleteAccountSetupView()

        case .completeAccountSetup:
            router.showCompleteAccountSetupView()

        case .notifications:
            router.showNotificationsPermissionsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showHealthDisclaimerView()

        case .goalSetting:
            router.showGoalSettingView()

        case .gymProfileSetup:
            let delegate = CreateGymProfileDelegate(onComplete: self.handleNavigation)
            router.showCreateGymProfileView(delegate: delegate)

        case .trainingProgramSetup:
            router.showOnboardingTrainingProgramView(delegate: CreateProgramDelegate(onComplete: self.handleNavigation))
        case .customiseProgram:
            router.showCustomisingDietProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }
    }

    // MARK: - Computed Properties
    
    var currentWeight: Double? {
        interactor.currentUser?.submittedWeightKilograms
    }
    
    var weightUnit: WeightUnitPreference {
        interactor.currentUser?.submittedWeightUnitPreference ?? .kilograms
    }
    
    func weightDifference(targetWeight: Double?) -> Double {
        guard let current = currentWeight else { return 0 }
        guard let target = targetWeight else { return 0 }
        return target - current
    }
    
    func estimatedWeeks(delegate: GoalSummaryDelegate) -> Int {
        return Int(ceil(abs(weightDifference(targetWeight: delegate.targetWeight)) / delegate.weightChangeRate))
    }
    
    func estimatedMonths(delegate: GoalSummaryDelegate) -> Int {
        Int(ceil(Double(estimatedWeeks(delegate: delegate)) / 4.33))
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
