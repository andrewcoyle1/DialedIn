//
//  OnboardingGoalSummaryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGoalSummaryInteractor {
    var currentUser: UserModel? { get }
    func createGoal(
        userId: String,
        objective: OverarchingObjective,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal
    func updateOnboardingStep(step: OnboardingStep) async throws
    func updateCurrentGoalId(goalId: String?) async throws
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingGoalSummaryInteractor { }

@Observable
@MainActor
class OnboardingGoalSummaryViewModel {
    private let interactor: OnboardingGoalSummaryInteractor
    
    let isStandaloneMode: Bool

    var isLoading: Bool = true
    var goalCreated: Bool = false
    var showAlert: AnyAppAlert?
    var onDismiss: (() -> Void)?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingGoalSummaryInteractor,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.isStandaloneMode = isStandaloneMode
    }
    
    private func navigateToCustomisingProgram(path: Binding<[OnboardingPathOption]>) async {
        try? await interactor.updateOnboardingStep(step: .customiseProgram)
        interactor.trackEvent(event: Event.navigate(destination: .customiseProgram))
        path.wrappedValue.append(.customiseProgram)
    }
    
    func uploadGoalSettings(path: Binding<[OnboardingPathOption]>, weightGoalBuilder: WeightGoalBuilder) {
        interactor.trackEvent(event: Event.goalSaveStart)
        defer { isLoading = false }

        Task {
            guard let user = interactor.currentUser,
                  let startingWeight = user.weightKilograms else {
                handleSaveError(NSError(domain: "GoalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current weight not available"]))
                return
            }

            guard let target = weightGoalBuilder.targetWeightKg,
                  let weekly = weightGoalBuilder.weeklyChangeKg else {
                handleSaveError(NSError(domain: "GoalError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Goal details incomplete"]))
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
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
                    onDismiss?()
                }

                await navigateToCustomisingProgram(path: path)
            } catch {
                interactor.trackEvent(event: Event.goalSaveFail(error: error))
                handleSaveError(error)
            }
        }
    }
    
    private func handleSaveError(_ error: Error) {
        let errorInfo = interactor.handleAuthError(error, operation: "save goal settings")
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message
        )
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
    
    enum Event: LoggableEvent {
        case goalSaveStart
        case goalSaveSuccess
        case goalSaveFail(error: Error)
        case navigate(destination: OnboardingPathOption)

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
            case .navigate(destination: let destination):
                return destination.eventParameters
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
