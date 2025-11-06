//
//  OnboardingExerciseFrequencyViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExerciseFrequencyInteractor {
    func trackEvent(event: LoggableEvent)
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

    var canSubmit: Bool {
        selectedFrequency != nil
    }
    
    init(interactor: OnboardingExerciseFrequencyInteractor) {
        self.interactor = interactor
    }
    
    func navigateToOnboardingActivity(path: Binding<[OnboardingPathOption]>, userBuilder: UserModelBuilder) {
        if let frequency = selectedFrequency {
            var builder = userBuilder
            builder.setExerciseFrequency(frequency)
            interactor.trackEvent(event: Event.navigate(destination: .activityLevel(userModelBuilder: builder)))
            path.wrappedValue.append(.activityLevel(userModelBuilder: builder))
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingExerciseFreqView_Navigate"
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
