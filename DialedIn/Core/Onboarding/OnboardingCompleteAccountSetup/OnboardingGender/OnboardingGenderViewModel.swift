//
//  OnboardingGenderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGenderInteractor {
    func updateGender(_ gender: Gender) throws
}

extension CoreInteractor: OnboardingGenderInteractor { }

@Observable
@MainActor
class OnboardingGenderViewModel {
    private let interactor: OnboardingGenderInteractor
    
    var selectedGender: Gender?
    var showAlert: AnyAppAlert?
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(interactor: OnboardingGenderInteractor) {
        self.interactor = interactor
    }
    
    func navigateToDateOfBirth(path: Binding<[OnboardingPathOption]>) {
        if let gender = selectedGender {
            do {
                try interactor.updateGender(gender)
                path.wrappedValue.append(.dateOfBirth)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}
