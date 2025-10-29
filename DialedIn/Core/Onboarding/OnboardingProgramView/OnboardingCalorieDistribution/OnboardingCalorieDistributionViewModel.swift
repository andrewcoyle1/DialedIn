//
//  OnboardingCalorieDistributionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingCalorieDistributionInteractor {
    
}

extension CoreInteractor: OnboardingCalorieDistributionInteractor { }

@Observable
@MainActor
class OnboardingCalorieDistributionViewModel {
    private let interactor: OnboardingCalorieDistributionInteractor
    
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    let trainingType: TrainingType
    
    var selectedCalorieDistribution: CalorieDistribution?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCalorieDistributionInteractor,
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor,
        trainingType: TrainingType
    ) {
        self.interactor = interactor
        self.preferredDiet = preferredDiet
        self.calorieFloor = calorieFloor
        self.trainingType = trainingType
    }
}

enum CalorieDistribution: String, CaseIterable, Identifiable {
    case even
    case varied
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .even:
            return "Distribute Evenly"
        case .varied:
            return "Vary By Day"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .even:
            return "Distribute calories evenly across all days of the week."
        case .varied:
            return "Distribute calories to increase energy on training days."
        }
    }
}
