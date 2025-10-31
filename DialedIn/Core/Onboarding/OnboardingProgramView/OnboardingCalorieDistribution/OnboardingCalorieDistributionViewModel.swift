//
//  OnboardingCalorieDistributionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCalorieDistributionInteractor {
    func setCalorieDistribution(_ value: CalorieDistribution)
}

extension CoreInteractor: OnboardingCalorieDistributionInteractor { }

@Observable
@MainActor
class OnboardingCalorieDistributionViewModel {
    private let interactor: OnboardingCalorieDistributionInteractor
        
    var selectedCalorieDistribution: CalorieDistribution?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCalorieDistributionInteractor,
    ) {
        self.interactor = interactor
    }
    
    func navigateToProteinIntake(path: Binding<[OnboardingPathOption]>) {
        if let calorieDistribution = selectedCalorieDistribution {
            interactor.setCalorieDistribution(calorieDistribution)
            path.wrappedValue.append(.proteinIntake)
        }
    }
}

enum CalorieDistribution: String, CaseIterable, Identifiable {
    case even
    case varied
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .even:
            return "Distribute Evenly"
        case .varied:
            return "Vary By Day"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .even:
            return "Distribute calories evenly across all days of the week."
        case .varied:
            return "Distribute calories to increase energy on training days."
        }
    }
}
