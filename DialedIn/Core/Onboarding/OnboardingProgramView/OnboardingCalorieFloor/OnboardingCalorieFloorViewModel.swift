//
//  OnboardingCalorieFloorViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingCalorieFloorInteractor {
    
}

extension CoreInteractor: OnboardingCalorieFloorInteractor { }

@Observable
@MainActor
class OnboardingCalorieFloorViewModel {
    private let interactor: OnboardingCalorieFloorInteractor
    
    let preferredDiet: PreferredDiet
    
    var navigationDestination: NavigationDestination?
    var selectedFloor: CalorieFloor?

    enum NavigationDestination {
        case trainingType
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCalorieFloorInteractor,
        preferredDiet: PreferredDiet
    ) {
        self.interactor = interactor
        self.preferredDiet = preferredDiet
    }
}
