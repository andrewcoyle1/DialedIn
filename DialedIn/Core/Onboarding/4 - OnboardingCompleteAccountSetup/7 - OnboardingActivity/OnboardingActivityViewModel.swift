//
//  OnboardingActivityViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingActivityInteractor {
    func trackEvent(event: LoggableEvent)
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
        
    var canSubmit: Bool {
        selectedActivityLevel != nil
    }
    
    init(interactor: OnboardingActivityInteractor) {
        self.interactor = interactor
    }
    
    func navigateToCardioFitness(path: Binding<[OnboardingPathOption]>, userBuilder: UserModelBuilder) {
        if let activityLevel = selectedActivityLevel {
            var builder = userBuilder
            builder.setActivityLevel(activityLevel)
            interactor.trackEvent(event: Event.navigate(destination: .cardioFitness(userModelBuilder: builder)))
            path.wrappedValue.append(.cardioFitness(userModelBuilder: builder))
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingActivityLevel_Navigate"
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
