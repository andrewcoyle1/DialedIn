//
//  ExerciseFrequencyPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseFrequencyPresenter {
    private let interactor: ExerciseFrequencyInteractor
    private let router: ExerciseFrequencyRouter

    var selectedFrequency: ExerciseFrequency?
    
    var canSubmit: Bool {
        selectedFrequency != nil
    }
    
    init(
        interactor: ExerciseFrequencyInteractor,
        router: ExerciseFrequencyRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinuePressed(delegate: ExerciseFrequencyDelegate) {
        guard let frequency = selectedFrequency else { return }
        let delegate = ActivityDelegate(delegate: delegate, exerciseFrequency: frequency)
        interactor.trackEvent(event: Event.navigate)
        router.showActivityView(delegate: delegate)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingExerciseFreqView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
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

enum ExerciseFrequency: String, CaseIterable, Codable {
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
