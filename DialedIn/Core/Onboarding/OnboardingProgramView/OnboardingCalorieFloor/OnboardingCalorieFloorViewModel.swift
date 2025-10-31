//
//  OnboardingCalorieFloorViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCalorieFloorInteractor {
    func setCalorieFloor(_ value: CalorieFloor)
}

extension CoreInteractor: OnboardingCalorieFloorInteractor { }

@Observable
@MainActor
class OnboardingCalorieFloorViewModel {
    private let interactor: OnboardingCalorieFloorInteractor
    
    var selectedFloor: CalorieFloor?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingCalorieFloorInteractor) {
        self.interactor = interactor
    }
    
    func navigateToTrainingType(path: Binding<[OnboardingPathOption]>) {
        if let floor = selectedFloor {
            interactor.setCalorieFloor(floor)
            path.wrappedValue.append(.trainingType)
        }
    }
}

enum CalorieFloor: String, CaseIterable, Identifiable {
    case standard
    case low
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard:
            return "Standard Floor (Recommended)"
        case .low:
            return "Low Floor"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .standard:
            return "Your recommendations will never go below 1200 calories per day, even if your TDEE is lower."
        case .low:
            return "Your recommendations will never go below 800 calories per day. Proceed with caution."
        }
    }
}
