//
//  OnboardingGenderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGenderInteractor {
    
}

extension CoreInteractor: OnboardingGenderInteractor { }

@Observable
@MainActor
class OnboardingGenderViewModel {
    private let interactor: OnboardingGenderInteractor
    
    var selectedGender: Gender?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(
        interactor: OnboardingGenderInteractor,
    ) {
        self.interactor = interactor
    }
    
    func navigateToDateOfBirth(path: Binding<[OnboardingPathOption]>) {
        if let gender = selectedGender {
            path.wrappedValue.append(.dateOfBirth(gender: gender))
        }
    }
}
