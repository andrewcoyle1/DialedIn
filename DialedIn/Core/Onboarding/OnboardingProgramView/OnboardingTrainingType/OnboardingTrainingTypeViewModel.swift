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
