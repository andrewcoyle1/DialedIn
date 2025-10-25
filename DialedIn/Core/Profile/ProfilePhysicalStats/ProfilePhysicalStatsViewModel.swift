//
//  ProfilePhysicalStatsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation

@Observable
@MainActor
class ProfilePhysicalStatsViewModel {
    private let userManager: UserManager
    private let userWeightManager: UserWeightManager
    
    private(set) var weights: [WeightEntry] = []

    var showLogWeightSheet: Bool = false

    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var weightHistory: [WeightEntry] {
        userWeightManager.weightHistory
    }
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.userWeightManager = container.resolve(UserWeightManager.self)!
    }
    
    func loadWeights() async {
        if let user = currentUser {
            weights = (try? await userWeightManager.getWeightHistory(userId: user.userId, limit: 5)) ?? []
        }
    }
    
    func formatHeight(_ heightCm: Double, unit: LengthUnitPreference) -> String {
        switch unit {
        case .centimeters:
            return String(format: "%.0f cm", heightCm)
        case .inches:
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        }
    }
    
    func formatWeight(_ weightKg: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
    
    enum BMICategory {
        case underweight
        case normal
        case overweight
        case obese
        
        var name: String {
            switch self {
            case .underweight:
                return "Underweight"
            case .normal:
                return "Normal"
            case .overweight:
                return "Overweight"
            case .obese:
                return "Obese"
            }
        }
        
        var color: Color {
            switch self {
            case .underweight:
                return .blue
            case .normal:
                return .green
            case .overweight:
                return .orange
            case .obese:
                return .red
            }
        }
        
        var description: String {
            switch self {
            case .underweight:
                return "A BMI below 18.5 may indicate underweight. Consider consulting a healthcare provider."
            case .normal:
                return "A BMI between 18.5 and 24.9 is considered healthy weight range."
            case .overweight:
                return "A BMI between 25.0 and 29.9 may indicate overweight. Consider a balanced diet and regular exercise."
            case .obese:
                return "A BMI of 30.0 or higher may indicate obesity. Consider consulting a healthcare provider for guidance."
            }
        }
    }
    
    func getBMICategory(_ bmi: Double) -> BMICategory {
        if bmi < 18.5 {
            return .underweight
        } else if bmi < 25.0 {
            return .normal
        } else if bmi < 30.0 {
            return .overweight
        } else {
            return .obese
        }
    }
    
    func formatExerciseFrequency(_ frequency: ProfileExerciseFrequency) -> String {
        switch frequency {
        case .never: return "Never"
        case .oneToTwo: return "1-2 times/week"
        case .threeToFour: return "3-4 times/week"
        case .fiveToSix: return "5-6 times/week"
        case .daily: return "Daily"
        }
    }
    
    func formatActivityLevel(_ level: ProfileDailyActivityLevel) -> String {
        switch level {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }
    
    func formatCardioFitness(_ level: ProfileCardioFitnessLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .elite: return "Elite"
        }
    }
}
