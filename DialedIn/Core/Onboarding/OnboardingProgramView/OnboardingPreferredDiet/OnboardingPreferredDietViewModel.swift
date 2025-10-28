//
//  OnboardingPreferredDietViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingPreferredDietInteractor {
    
}

extension CoreInteractor: OnboardingPreferredDietInteractor { }

@Observable
@MainActor
class OnboardingPreferredDietViewModel {
    private let interactor: OnboardingPreferredDietInteractor
    
    var selectedDiet: PreferredDiet?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingPreferredDietInteractor
    ) {
        self.interactor = interactor
    }
}
