//
//  OnboardingExerciseFrequencyViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExerciseFrequencyInteractor {
    
}

extension CoreInteractor: OnboardingExerciseFrequencyInteractor { }

@Observable
@MainActor
class OnboardingExerciseFrequencyViewModel {
    private let interactor: OnboardingExerciseFrequencyInteractor
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    var selectedFrequency: ExerciseFrequency?
    var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case activity(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, exerciseFrequency: ExerciseFrequency, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedFrequency != nil
    }
    
    init(
        interactor: OnboardingExerciseFrequencyInteractor,
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    ) {
        self.interactor = interactor
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.lengthUnitPreference = lengthUnitPreference
        self.weightUnitPreference = weightUnitPreference
    }
    
    func navigateToOnboardingActivity(path: Binding<[OnboardingPathOption]>) {
        if let frequency = selectedFrequency {
            path.wrappedValue.append(.activityLevel(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, exerciseFrequency: frequency, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference))
        }
    }
}

enum ExerciseFrequency: String, CaseIterable {
    case never = "never"
    case oneToTwo = "1-2"
    case threeToFour = "3-4"
    case fiveToSix = "5-6"
    case daily = "daily"
    
    var description: String {
        switch self {
        case .never:
            return "Never"
        case .oneToTwo:
            return "1-2 times per week"
        case .threeToFour:
            return "3-4 times per week"
        case .fiveToSix:
            return "5-6 times per week"
        case .daily:
            return "Daily"
        }
    }
}
