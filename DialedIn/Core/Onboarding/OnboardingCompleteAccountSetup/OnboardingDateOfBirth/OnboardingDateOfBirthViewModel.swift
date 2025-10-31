//
//  OnboardingDateOfBirthViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingDateOfBirthInteractor {
    var userDraft: UserModel? { get }
    func updateDateOfBirth(_ dateOfBirth: Date) throws
}

extension CoreInteractor: OnboardingDateOfBirthInteractor { }

@Observable
@MainActor
class OnboardingDateOfBirthViewModel {
    private let interactor: OnboardingDateOfBirthInteractor
    
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    var showAlert: AnyAppAlert?
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingDateOfBirthInteractor) {
        self.interactor = interactor
    }
    
    func navigateToOnboardingHeight(path: Binding<[OnboardingPathOption]>) {
        do {
            try interactor.updateDateOfBirth(dateOfBirth)
            path.wrappedValue.append(.height)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
