//
//  OnboardingWeightRateViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingWeightRateInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingWeightRateInteractor { }

@Observable
@MainActor
class OnboardingWeightRateViewModel {
    private let interactor: OnboardingWeightRateInteractor
    
    let objective: OverarchingObjective
    let targetWeight: Double
    let isStandaloneMode: Bool
    
    var navigationDestination: NavigationDestination?
    var currentWeight: Double = 0
    var weightUnit: WeightUnitPreference = .kilograms
    var didInitialize: Bool = false
    var weightChangeRate: Double = 0.5 // kg/week
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    enum NavigationDestination {
        case customisingProgram
    }
    
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
    
    init(
        interactor: OnboardingWeightRateInteractor,
        objective: OverarchingObjective,
        targetWeight: Double,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.objective = objective
        self.targetWeight = targetWeight
        self.isStandaloneMode = isStandaloneMode
    }
    
    func navigateToGoalSummary(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.goalSummary(objective: objective, targetWeight: targetWeight, weightRate: weightChangeRate))
    }
    
    var canContinue: Bool { weightChangeRate > 0 }
    
    // MARK: - Computed Properties
    
    var weeklyWeightChangeText: String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = objective == .loseWeight ? "-" : "+"
        let percentBW = (weeklyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", weeklyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Week"
    }
    
    var monthlyWeightChangeText: String {
        let monthlyChangeInKg = weightChangeRate * 4 // Approximate monthly rate
        let monthlyChangeInPounds = weightUnit == .pounds ? monthlyChangeInKg * 2.20462 : monthlyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = objective == .loseWeight ? "-" : "+"
        let percentBW = (monthlyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", monthlyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Month"
    }
    
    var estimatedCalorieTargetText: String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        
        // Rough estimate: 1 lb = ~3500 calories, so weekly deficit/surplus
        let weeklyCalorieChange = weeklyChangeInPounds * 3500
        let dailyCalorieChange = weeklyCalorieChange / 7
        
        let baseCalories = 2000.0 // Rough BMR estimate
        let targetCalories = objective == .loseWeight ?
            baseCalories - dailyCalorieChange :
            baseCalories + dailyCalorieChange
        
        return "~ \(Int(targetCalories)) kcal estimated daily calorie target"
    }
    
    var estimatedEndDateText: String {
        let totalWeightChange = abs(targetWeight - currentWeight)
        let weeklyChangeInKg = weightChangeRate
        let weeksToGoal = totalWeightChange / weeklyChangeInKg
        
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: Int(weeksToGoal), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Approximate end date: \(formatter.string(from: endDate))"
    }
    
    // MARK: - Helper Methods
    
    func onAppear() {
        let user = interactor.currentUser
        currentWeight = user?.weightKilograms ?? 70
        weightUnit = user?.weightUnitPreference ?? .kilograms
        
        // Set default rate based on objective
        switch objective {
        case .loseWeight, .gainWeight:
            weightChangeRate = 0.5 // Standard rate
        case .maintain:
            weightChangeRate = 0.25 // Conservative rate
        }
        
        didInitialize = true
    }
}
