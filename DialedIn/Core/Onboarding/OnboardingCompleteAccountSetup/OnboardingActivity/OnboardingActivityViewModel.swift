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
