//
//  OnboardingGenderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingGenderInteractor {
    
}

extension CoreInteractor: OnboardingGenderInteractor { }

@Observable
@MainActor
class OnboardingGenderViewModel {
    private let interactor: OnboardingGenderInteractor
    
    var selectedGender: Gender?
    var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case dateOfBirth(gender: Gender)
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(
        interactor: OnboardingGenderInteractor
    ) {
        self.interactor = interactor
    }
}
