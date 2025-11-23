//
//  ProfilePhysicalMetricsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfilePhysicalMetricsInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfilePhysicalMetricsInteractor { }

@MainActor
protocol ProfilePhysicalMetricsRouter {
    func showPhysicalStatsView()
    func showDevSettingsView()
}

extension CoreRouter: ProfilePhysicalMetricsRouter { }

@Observable
@MainActor
class ProfilePhysicalMetricsViewModel {
    private let interactor: ProfilePhysicalMetricsInteractor
    private let router: ProfilePhysicalMetricsRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    init(
        interactor: ProfilePhysicalMetricsInteractor,
        router: ProfilePhysicalMetricsRouter
    ) {
        self.interactor = interactor
        self.router = router
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

    func navToPhysicalStats() {
        interactor.trackEvent(event: Event.navigate)
        router.showPhysicalStatsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "PhysicalMetricsView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
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
