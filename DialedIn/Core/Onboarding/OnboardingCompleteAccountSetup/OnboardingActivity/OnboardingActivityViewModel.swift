//
//  OnboardingActivityViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingActivityInteractor {
    
}

extension CoreInteractor: OnboardingActivityInteractor { }

@Observable
@MainActor
class OnboardingActivityViewModel {
    private let interactor: OnboardingActivityInteractor
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    var selectedActivityLevel: ActivityLevel?
    var navigationDestination: NavigationDestination?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedActivityLevel != nil
    }
    
    init(
        interactor: OnboardingActivityInteractor,
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    ) {
        self.interactor = interactor
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.exerciseFrequency = exerciseFrequency
        self.lengthUnitPreference = lengthUnitPreference
        self.weightUnitPreference = weightUnitPreference
    }
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    var description: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .light:
            return "Light Activity"
        case .moderate:
            return "Moderate Activity"
        case .active:
            return "Active"
        case .veryActive:
            return "Very Active"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .sedentary:
            return "Desk job, minimal walking, mostly sitting"
        case .light:
            return "Light walking, some daily activities, occasional stairs"
        case .moderate:
            return "Regular walking, standing work, daily movement"
        case .active:
            return "Active lifestyle, frequent movement, manual work"
        case .veryActive:
            return "Highly active, constant movement, physically demanding"
        }
    }
}
