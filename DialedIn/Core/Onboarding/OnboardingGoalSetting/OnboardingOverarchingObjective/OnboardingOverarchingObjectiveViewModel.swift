//
//  OnboardingOverarchingObjectiveViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingOverarchingObjectiveInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingOverarchingObjectiveInteractor { }

@Observable
@MainActor
class OnboardingOverarchingObjectiveViewModel {
    private let interactor: OnboardingOverarchingObjectiveInteractor
    
    let isStandaloneMode: Bool
    
    var selectedObjective: OverarchingObjective?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var userWeight: Double? {
        interactor.currentUser?.weightKilograms
    }
    
    var canContinue: Bool { selectedObjective != nil && userWeight != nil }
    
    init(
        interactor: OnboardingOverarchingObjectiveInteractor,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.isStandaloneMode = isStandaloneMode
    }
}

enum OverarchingObjective: CaseIterable {
    case loseWeight
    case maintain
    case gainWeight
    
    var description: String {
        switch self {
        case .loseWeight:
            "Lose weight"
        case .maintain:
            "Maintain"
        case .gainWeight:
            "Gain weight"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .loseWeight:
            "Goal of losing weight"
        case .maintain:
            "Goal of maintaining weight"
        case .gainWeight:
            "Goal of gaining weight"
        }
    }
}
