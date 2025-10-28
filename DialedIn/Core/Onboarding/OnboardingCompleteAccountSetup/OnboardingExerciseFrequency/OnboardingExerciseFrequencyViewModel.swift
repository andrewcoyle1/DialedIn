//
//  OnboardingExerciseFrequencyViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

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
}
