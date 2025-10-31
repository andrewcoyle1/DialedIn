//
//  OnboardingTrainingTypeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingTrainingTypeInteractor {
    func setTrainingType(_ value: TrainingType)
}

extension CoreInteractor: OnboardingTrainingTypeInteractor { }

@Observable
@MainActor
class OnboardingTrainingTypeViewModel {
    private let interactor: OnboardingTrainingTypeInteractor
        
    var selectedTrainingType: TrainingType?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingTypeInteractor) {
        self.interactor = interactor
    }
    
    func navigateToCalorieDistribution(path: Binding<[OnboardingPathOption]>) {
        if let trainingType = selectedTrainingType {
            interactor.setTrainingType(trainingType)
            path.wrappedValue.append(.calorieDistribution)
        }
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
