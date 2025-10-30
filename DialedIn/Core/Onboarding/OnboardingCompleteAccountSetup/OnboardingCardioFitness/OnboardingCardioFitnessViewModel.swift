//
//  OnboardingCardioFitnessViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

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
    
    func navigateToExpenditure(path: Binding<[OnboardingPathOption]>) {
        if let cardioFitness = selectedCardioFitness {
            path.wrappedValue
                .append(
                    .expenditure(
                        gender: gender,
                        dateOfBirth: dateOfBirth,
                        height: height,
                        weight: weight,
                        exerciseFrequency: exerciseFrequency,
                        activityLevel: activityLevel,
                        lengthUnitPreference: lengthUnitPreference,
                        weightUnitPreference: weightUnitPreference,
                        selectedCardioFitness: cardioFitness
                    )
                )
        }
    }
}

enum CardioFitnessLevel: String, CaseIterable {
    case beginner
    case novice
    case intermediate
    case advanced
    case elite
    
    var description: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .novice:
            return "Novice"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .elite:
            return "Elite"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .beginner:
            return "Just starting cardio, gets winded easily, low endurance"
        case .novice:
            return "Some cardio experience, can handle light jogging, moderate endurance"
        case .intermediate:
            return "Regular cardio, comfortable running, good endurance"
        case .advanced:
            return "Experienced runner, high endurance, can maintain pace"
        case .elite:
            return "Athlete level, exceptional endurance, competitive fitness"
        }
    }
}
