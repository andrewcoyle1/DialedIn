//
//  OnboardingTrainingTypeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingTrainingTypeInteractor {
    
}

extension CoreInteractor: OnboardingTrainingTypeInteractor { }

@Observable
@MainActor
class OnboardingTrainingTypeViewModel {
    private let interactor: OnboardingTrainingTypeInteractor
    
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    
    var selectedTrainingType: TrainingType?
    var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case calorieDistribution
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingTrainingTypeInteractor,
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor
    ) {
        self.interactor = interactor
        self.preferredDiet = preferredDiet
        self.calorieFloor = calorieFloor
    }
}

enum TrainingType: String, CaseIterable, Identifiable {
    case noneOrRelaxedActivity
    case weightlifting
    case cardio
    case cardioAndWeightlifting
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .noneOrRelaxedActivity:
            return "None or relaxed activity"
        case .weightlifting:
            return "Weightlifting"
        case .cardio:
            return "Cardio"
        case .cardioAndWeightlifting:
            return "Cardio and weightlifting"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .noneOrRelaxedActivity:
            return "No exercise, or light, relaxed activity."
        case .weightlifting:
            return "Strength training, such as weightlifting, bodyweight exercises, or resistance band workouts."
        case .cardio:
            return "Cardiovascular exercise, such as running, cycling, swimming, or brisk walking."
        case .cardioAndWeightlifting:
            return "A combination of cardiovascular and strength training exercises."
        }
    }
}
