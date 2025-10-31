//
//  OnboardingActivityViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingActivityInteractor {
    func updateUserActivityLevel(_ activityLevel: ActivityLevel) throws
}

extension CoreInteractor: OnboardingActivityInteractor { }

@Observable
@MainActor
class OnboardingActivityViewModel {
    private let interactor: OnboardingActivityInteractor
        
    var selectedActivityLevel: ActivityLevel?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var showAlert: AnyAppAlert?
    
    var canSubmit: Bool {
        selectedActivityLevel != nil
    }
    
    init(
        interactor: OnboardingActivityInteractor,
    ) {
        self.interactor = interactor
    }
    
    func navigateToCardioFitness(path: Binding<[OnboardingPathOption]>) {
        if let activityLevel = selectedActivityLevel {
            do {
                try interactor.updateUserActivityLevel(activityLevel)
                path.wrappedValue.append(.cardioFitness)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    var description: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .light:
            return "Light Activity"
        case .moderate:
            return "Moderate Activity"
        case .active:
            return "Active"
        case .veryActive:
            return "Very Active"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .sedentary:
            return "Desk job, minimal walking, mostly sitting"
        case .light:
            return "Light walking, some daily activities, occasional stairs"
        case .moderate:
            return "Regular walking, standing work, daily movement"
        case .active:
            return "Active lifestyle, frequent movement, manual work"
        case .veryActive:
            return "Highly active, constant movement, physically demanding"
        }
    }
}
