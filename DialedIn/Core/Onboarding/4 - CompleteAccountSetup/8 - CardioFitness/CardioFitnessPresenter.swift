//
//  CardioFitnessPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class CardioFitnessPresenter {
    private let interactor: CardioFitnessInteractor
    private let router: CardioFitnessRouter

    var selectedCardioFitness: CardioFitnessLevel?
        
    var canSubmit: Bool {
        selectedCardioFitness != nil
    }

    init(
        interactor: CardioFitnessInteractor,
        router: CardioFitnessRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinuePressed(delegate: CardioFitnessDelegate) {
        guard let cardioFitness = selectedCardioFitness else { return }
        let delegate = ExpenditureDelegate(delegate: delegate, cardioFitnessLevel: cardioFitness)
        interactor.trackEvent(event: Event.navigate)
        router.showExpenditureView(delegate: delegate)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "CardioFitness_Navigate"
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

enum CardioFitnessLevel: String, CaseIterable, Codable {
    case beginner
    case novice
    case intermediate
    case advanced
    case elite
    
    var description: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .novice:
            return "Novice"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .elite:
            return "Elite"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .beginner:
            return "Just starting cardio, gets winded easily, low endurance"
        case .novice:
            return "Some cardio experience, can handle light jogging, moderate endurance"
        case .intermediate:
            return "Regular cardio, comfortable running, good endurance"
        case .advanced:
            return "Experienced runner, high endurance, can maintain pace"
        case .elite:
            return "Athlete level, exceptional endurance, competitive fitness"
        }
    }
}
