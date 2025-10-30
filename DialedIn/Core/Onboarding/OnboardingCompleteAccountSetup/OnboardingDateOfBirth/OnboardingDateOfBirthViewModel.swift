//
//  OnboardingDateOfBirthViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingDateOfBirthInteractor {
    
}

extension CoreInteractor: OnboardingDateOfBirthInteractor { }

@Observable
@MainActor
class OnboardingDateOfBirthViewModel {
    private let interactor: OnboardingDateOfBirthInteractor
    
    let gender: Gender
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case height(gender: Gender, dateOfBirth: Date)
    }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingDateOfBirthInteractor,
        gender: Gender
    ) {
        self.interactor = interactor
        self.gender = gender
    }
    
    func navigateToOnboardingHeight(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.height(gender: gender, dateOfBirth: dateOfBirth))
    }
}
