//
//  OnboardingCalorieFloorViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCalorieFloorInteractor {
    func setCalorieFloor(_ value: CalorieFloor)
    func trackEvent(event: LoggableEvent)
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
            interactor.trackEvent(event: Event.navigate(destination: .trainingType))
            path.wrappedValue.append(.trainingType)
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_CalFloor_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
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
