//
//  OnboardingExerciseFrequencyViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExerciseFrequencyInteractor {
    func updateUserExerciseFrequency(_ frequency: ExerciseFrequency) throws
}

extension CoreInteractor: OnboardingExerciseFrequencyInteractor { }

@Observable
@MainActor
class OnboardingExerciseFrequencyViewModel {
    private let interactor: OnboardingExerciseFrequencyInteractor
        
    var selectedFrequency: ExerciseFrequency?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var showAlert: AnyAppAlert?
    
    var canSubmit: Bool {
        selectedFrequency != nil
    }
    
    init(interactor: OnboardingExerciseFrequencyInteractor) {
        self.interactor = interactor
    }
    
    func navigateToOnboardingActivity(path: Binding<[OnboardingPathOption]>) {
        if let frequency = selectedFrequency {
            do {
                try interactor.updateUserExerciseFrequency(frequency)
                path.wrappedValue.append(.activityLevel)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

enum ExerciseFrequency: String, CaseIterable {
    case never = "never"
    case oneToTwo = "1-2"
    case threeToFour = "3-4"
    case fiveToSix = "5-6"
    case daily = "daily"
    
    var description: String {
        switch self {
        case .never:
            return "Never"
        case .oneToTwo:
            return "1-2 times per week"
        case .threeToFour:
            return "3-4 times per week"
        case .fiveToSix:
            return "5-6 times per week"
        case .daily:
            return "Daily"
        }
    }
}
