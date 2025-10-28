//
//  OnboardingGoalSummaryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingGoalSummaryInteractor {
    var currentUser: UserModel? { get }
    func createGoal(
        userId: String,
        objective: String,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal
    func updateCurrentGoalId(goalId: String?) async throws
    func trackEvent(event: LoggableEvent)
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
}

extension CoreInteractor: OnboardingGoalSummaryInteractor { }

@Observable
@MainActor
class OnboardingGoalSummaryViewModel {
    private let interactor: OnboardingGoalSummaryInteractor
    
    let objective: OverarchingObjective
    let targetWeight: Double
    let weightRate: Double
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
        objective: OverarchingObjective,
        targetWeight: Double,
        weightRate: Double,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.objective = objective
        self.targetWeight = targetWeight
        self.weightRate = weightRate
        self.isStandaloneMode = isStandaloneMode
    }
    
    func uploadGoalSettings() async {
        interactor.trackEvent(event: Event.goalSaveStart(objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
        defer { isLoading = false }
        
        guard let user = interactor.currentUser,
              let startingWeight = user.weightKilograms else {
            handleSaveError(NSError(domain: "GoalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current weight not available"]))
            return
        }
        
        do {
            // Create goal in subcollection with frozen starting weight
            let goal = try await interactor.createGoal(
                userId: user.userId,
                objective: objective.description,
                startingWeightKg: startingWeight,
                targetWeightKg: targetWeight,
                weeklyChangeKg: weightRate
            )
            
            // Update user's currentGoalId reference
            try await interactor.updateCurrentGoalId(goalId: goal.goalId)
            
            interactor.trackEvent(event: Event.goalSaveSuccess(objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
            
            goalCreated = true
            
            // If standalone mode, auto-dismiss after a brief delay
            if isStandaloneMode {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
                onDismiss?()
            }
        } catch {
            interactor.trackEvent(event: Event.goalSaveFail(error: error, objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
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
        return targetWeight - current
    }
    
    var estimatedWeeks: Int {
        guard weightRate > 0 else { return 0 }
        return Int(ceil(abs(weightDifference) / weightRate))
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
        switch objective {
        case .loseWeight:
            return "arrow.down.circle.fill"
        case .maintain:
            return "equal.circle.fill"
        case .gainWeight:
            return "arrow.up.circle.fill"
        }
    }
    
    var motivationalMessage: String {
        switch objective {
        case .loseWeight:
            return "Every step you take towards your goal is progress. Stay consistent with your nutrition and exercise, and you'll reach your target weight. Remember, sustainable changes lead to lasting results."
        case .maintain:
            return "Maintaining your current weight is a fantastic goal! Focus on balanced nutrition and regular activity to keep your body healthy and strong. Consistency is key to long-term success."
        case .gainWeight:
            return "Building healthy weight takes time and dedication. Focus on nutrient-dense foods and progressive strength training. Your body will thank you for the consistent effort."
        }
    }
    
    enum Event: LoggableEvent {
        case goalSaveStart(objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        case goalSaveSuccess(objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        case goalSaveFail(error: Error, objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        
        var eventName: String {
            switch self {
            case .goalSaveStart: return "Onboarding_Goal_Save_Start"
            case .goalSaveSuccess: return "Onboarding_Goal_Save_Success"
            case .goalSaveFail: return "Onboarding_Goal_Save_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case let .goalSaveStart(objective, targetKg, rateKgPerWeek),
                 let .goalSaveSuccess(objective, targetKg, rateKgPerWeek):
                return [
                    "objective": objective.description,
                    "target_weight_kg": targetKg,
                    "weekly_change_kg": rateKgPerWeek
                ]
            case let .goalSaveFail(error, objective, targetKg, rateKgPerWeek):
                return [
                    "objective": objective.description,
                    "target_weight_kg": targetKg,
                    "weekly_change_kg": rateKgPerWeek,
                    "error": error.localizedDescription
                ]
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
