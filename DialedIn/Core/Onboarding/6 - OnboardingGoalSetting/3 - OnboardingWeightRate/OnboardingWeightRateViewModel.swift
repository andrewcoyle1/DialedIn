//
//  OnboardingWeightRateViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingWeightRateInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingWeightRateInteractor { }

@Observable
@MainActor
class OnboardingWeightRateViewModel {
    private let interactor: OnboardingWeightRateInteractor
    
    let isStandaloneMode: Bool
    
    var currentWeight: Double = 0
    var weightUnit: WeightUnitPreference = .kilograms
    var didInitialize: Bool = false
    var weightChangeRate: Double = 0.5 // kg/week
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    enum WeightRateCategory {
        case conservative, standard, aggressive
        
        var title: String {
            switch self {
            case .conservative: return "Conservative"
            case .standard: return "Standard (Recommended)"
            case .aggressive: return "Aggressive"
            }
        }
    }
    
    // MARK: - Constants
    let minWeightChangeRate: Double = 0.25 // kg/week
    let maxWeightChangeRate: Double = 1.5  // kg/week
    let conservativeThreshold: Double = 0.4 // kg/week
    let aggressiveThreshold: Double = 0.8  // kg/week
    
    var currentRateCategory: WeightRateCategory {
        if weightChangeRate <= conservativeThreshold {
            return .conservative
        } else if weightChangeRate >= aggressiveThreshold {
            return .aggressive
        } else {
            return .standard
        }
    }

    var canContinue: Bool { weightChangeRate > 0 }

    init(
        interactor: OnboardingWeightRateInteractor,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.isStandaloneMode = isStandaloneMode
    }

    func onAppear(weightGoalBuilder: WeightGoalBuilder) {
        let user = interactor.currentUser
        currentWeight = user?.weightKilograms ?? 70
        weightUnit = user?.weightUnitPreference ?? .kilograms

        let objective = weightGoalBuilder.objective
        // Set default rate based on objective
        if objective == .maintain {
            weightChangeRate = 0
        } else if objective == .loseWeight {
            weightChangeRate = 0.5
        } else if objective == .gainWeight {
            weightChangeRate = 0.25
        }

        // If draft already has a weekly rate, reflect it
        if let rate = weightGoalBuilder.weeklyChangeKg, rate > 0 {
            weightChangeRate = rate
        }

        didInitialize = true
    }

    func navigateToGoalSummary(path: Binding<[OnboardingPathOption]>, weightGoalBuilder: WeightGoalBuilder) {
        var builder = weightGoalBuilder
        builder.setWeeklyChange(weightChangeRate)
        interactor.trackEvent(event: Event.navigate(destination: .goalSummary(weightGoalBuilder: builder)))
        path.wrappedValue.append(.goalSummary(weightGoalBuilder: builder))
    }

    func weeklyWeightChangeText(weightGoalBuilder: WeightGoalBuilder) -> String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = weightGoalBuilder.objective == .loseWeight ? "-" : "+"
        let percentBW = (weeklyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", weeklyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Week"
    }
    
    func monthlyWeightChangeText(weightGoalBuilder: WeightGoalBuilder) -> String {
        let monthlyChangeInKg = weightChangeRate * 4 // Approximate monthly rate
        let monthlyChangeInPounds = weightUnit == .pounds ? monthlyChangeInKg * 2.20462 : monthlyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = weightGoalBuilder.objective == .loseWeight ? "-" : "+"
        let percentBW = (monthlyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", monthlyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Month"
    }
    
    func estimatedCalorieTargetText(weightGoalBuilder: WeightGoalBuilder) -> String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        
        // Rough estimate: 1 lb = ~3500 calories, so weekly deficit/surplus
        let weeklyCalorieChange = weeklyChangeInPounds * 3500
        let dailyCalorieChange = weeklyCalorieChange / 7
        
        let baseCalories = 2000.0 // Rough BMR estimate
        let targetCalories = weightGoalBuilder.objective == .loseWeight ?
            baseCalories - dailyCalorieChange :
            baseCalories + dailyCalorieChange
        
        return "~ \(Int(targetCalories)) kcal estimated daily calorie target"
    }
    
    func estimatedEndDateText(weightGoalBuilder: WeightGoalBuilder) -> String {
        let target = weightGoalBuilder.targetWeightKg ?? currentWeight
        let totalWeightChange = abs(target - currentWeight)
        let weeklyChangeInKg = weightChangeRate
        let weeksToGoal = totalWeightChange / weeklyChangeInKg
        
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: Int(weeksToGoal), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Approximate end date: \(formatter.string(from: endDate))"
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_WeightRate_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
