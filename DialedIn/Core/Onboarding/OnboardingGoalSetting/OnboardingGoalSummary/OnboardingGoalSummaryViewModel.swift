//
//  OnboardingGoalSummaryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGoalSummaryInteractor {
    var currentUser: UserModel? { get }
    var userDraft: UserModel? { get }
    var goalDraft: GoalDraft { get }
    func createGoal(
        userId: String,
        objective: String,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal
    func updateCurrentGoalId(goalId: String?) async throws
    func resetGoalDraft()
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
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
    
    var userDraft: UserModel? {
        interactor.userDraft
    }
    
    var goalDraft: GoalDraft {
        interactor.goalDraft
    }
    
    init(
        interactor: OnboardingGoalSummaryInteractor,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.isStandaloneMode = isStandaloneMode
    }
    
    func navigateToCustomisingProgram(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.customiseProgram)
    }
    
    func uploadGoalSettings() async {
        interactor.trackEvent(event: Event.goalSaveStart)
        defer { isLoading = false }
        
        guard let user = interactor.currentUser,
              let startingWeight = user.weightKilograms else {
            handleSaveError(NSError(domain: "GoalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current weight not available"]))
            return
        }
        
        guard let objective = goalDraft.objective,
              let target = goalDraft.targetWeightKg,
              let weekly = goalDraft.weeklyChangeKg else {
            handleSaveError(NSError(domain: "GoalError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Goal details incomplete"]))
            return
        }
        
        do {
            // Create goal in subcollection with frozen starting weight
            let goal = try await interactor.createGoal(userId: user.userId, objective: objective, startingWeightKg: startingWeight, targetWeightKg: target, weeklyChangeKg: weekly)
            
            // Update user's currentGoalId reference
            try await interactor.updateCurrentGoalId(goalId: goal.goalId)
            
            interactor.resetGoalDraft()
            
            interactor.trackEvent(event: Event.goalSaveSuccess)
            
            goalCreated = true
            
            // If standalone mode, auto-dismiss after a brief delay
            if isStandaloneMode {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
                onDismiss?()
            }
        } catch {
            interactor.trackEvent(event: Event.goalSaveFail(error: error))
            handleSaveError(error)
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
    
    var weightDifference: Double {
        guard let current = currentWeight else { return 0 }
        guard let target = goalDraft.targetWeightKg else { return 0 }
        return target - current
    }
    
    var estimatedWeeks: Int {
        guard let rate = goalDraft.weeklyChangeKg, rate > 0 else { return 0 }
        return Int(ceil(abs(weightDifference) / rate))
    }
    
    var estimatedMonths: Int {
        Int(ceil(Double(estimatedWeeks) / 4.33))
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
    
    var objectiveIcon: String {
        let objective = goalDraft.objective?.lowercased() ?? ""
        if objective.contains("lose") { return "arrow.down.circle.fill" }
        if objective.contains("maintain") { return "equal.circle.fill" }
        return "arrow.up.circle.fill"
    }
    
    var motivationalMessage: String {
        let objective = goalDraft.objective?.lowercased() ?? ""
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
        
        var eventName: String {
            switch self {
            case .goalSaveStart: return "Onboarding_Goal_Save_Start"
            case .goalSaveSuccess: return "Onboarding_Goal_Save_Success"
            case .goalSaveFail: return "Onboarding_Goal_Save_Fail"
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
            default:
                return .analytic
            }
        }
    }
}
