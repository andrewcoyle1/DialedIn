//
//  OnboardingCardioFitnessViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingCardioFitnessInteractor {
    
}

extension CoreInteractor: OnboardingCardioFitnessInteractor { }

@Observable
@MainActor
class OnboardingCardioFitnessViewModel {
    private let interactor: OnboardingCardioFitnessInteractor
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    var selectedCardioFitness: CardioFitnessLevel?
    var navigationDestination: NavigationDestination?
    var showAlert: AnyAppAlert?
    var isSaving: Bool = false
    var currentSaveTask: Task<Void, Never>?
    
    enum NavigationDestination {
        case expenditure
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedCardioFitness != nil
    }

    init(
        interactor: OnboardingCardioFitnessInteractor,
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        activityLevel: ActivityLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    ) {
        self.interactor = interactor
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.exerciseFrequency = exerciseFrequency
        self.activityLevel = activityLevel
        self.lengthUnitPreference = lengthUnitPreference
        self.weightUnitPreference = weightUnitPreference
    }
}
