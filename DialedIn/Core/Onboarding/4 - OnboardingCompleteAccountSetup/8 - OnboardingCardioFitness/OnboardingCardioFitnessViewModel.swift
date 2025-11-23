//
//  OnboardingCardioFitnessViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCardioFitnessInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCardioFitnessInteractor { }

@MainActor
protocol OnboardingCardioFitnessRouter {
    func showDevSettingsView()
    func showOnboardingExpenditureView(delegate: OnboardingExpenditureViewDelegate)
}

extension CoreRouter: OnboardingCardioFitnessRouter { }

@Observable
@MainActor
class OnboardingCardioFitnessViewModel {
    private let interactor: OnboardingCardioFitnessInteractor
    private let router: OnboardingCardioFitnessRouter

    var selectedCardioFitness: CardioFitnessLevel?
    var isSaving: Bool = false
    var currentSaveTask: Task<Void, Never>?
        
    var canSubmit: Bool {
        selectedCardioFitness != nil
    }

    init(
        interactor: OnboardingCardioFitnessInteractor,
        router: OnboardingCardioFitnessRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToExpenditure(userBuilder: UserModelBuilder) {
        if let cardioFitness = selectedCardioFitness {
            var builder = userBuilder
            builder.setCardioFitness(cardioFitness)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingExpenditureView(delegate: OnboardingExpenditureViewDelegate(userBuilder: builder))
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingCardioFitness_Navigate"
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

enum CardioFitnessLevel: String, CaseIterable {
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
