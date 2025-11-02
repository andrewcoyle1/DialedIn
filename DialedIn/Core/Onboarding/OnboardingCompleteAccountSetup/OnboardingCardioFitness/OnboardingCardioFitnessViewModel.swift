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

@Observable
@MainActor
class OnboardingCardioFitnessViewModel {
    private let interactor: OnboardingCardioFitnessInteractor
    
    var selectedCardioFitness: CardioFitnessLevel?
    var isSaving: Bool = false
    var currentSaveTask: Task<Void, Never>?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedCardioFitness != nil
    }

    init(interactor: OnboardingCardioFitnessInteractor) {
        self.interactor = interactor
    }
    
    func navigateToExpenditure(path: Binding<[OnboardingPathOption]>, userBuilder: UserModelBuilder) {
        if let cardioFitness = selectedCardioFitness {
            var builder = userBuilder
            builder.setCardioFitness(cardioFitness)
            interactor.trackEvent(event: Event.navigate(destination: .expenditure(userModelBuilder: builder)))
            path.wrappedValue.append(.expenditure(userModelBuilder: builder))
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingCardioFitness_Navigate"
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
