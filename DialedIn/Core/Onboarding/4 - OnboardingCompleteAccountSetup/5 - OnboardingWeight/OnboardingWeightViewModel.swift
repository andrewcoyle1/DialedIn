//
//  OnboardingWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingWeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingWeightInteractor { }

@MainActor
protocol OnboardingWeightRouter {
    func showDevSettingsView()
    func showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyViewDelegate)
}

extension CoreRouter: OnboardingWeightRouter { }

@Observable
@MainActor
class OnboardingWeightViewModel {
    private let interactor: OnboardingWeightInteractor
    private let router: OnboardingWeightRouter

    var unit: UnitOfWeight = .kilograms
    var selectedKilograms: Int = 70
    var selectedPounds: Int = 154
    
    var showAlert: AnyAppAlert?
    
    var weight: Double {
        switch unit {
        case .kilograms:
            Double(selectedKilograms)
        case .pounds:
            Double(selectedPounds) * 0.453592
        }
    }
    
    var preference: WeightUnitPreference {
        switch unit {
        case .kilograms:
            return .kilograms
        case .pounds:
            return .pounds
        }
    }
    
    enum UnitOfWeight {
        case kilograms
        case pounds
    }
    
    var canSubmit: Bool {
        switch unit {
        case .kilograms:
            return (30...200).contains(selectedKilograms)
        case .pounds:
            return (66...440).contains(selectedPounds)
        }
    }
    
    func updatePoundsFromKilograms() {
        selectedPounds = Int(Double(selectedKilograms) * 2.20462)
    }
    
    func updateKilogramsFromPounds() {
        selectedKilograms = Int(Double(selectedPounds) / 2.20462)
    }
    
    init(
        interactor: OnboardingWeightInteractor,
        router: OnboardingWeightRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToExerciseFrequency(userBuilder: UserModelBuilder) {
        var builder = userBuilder
        builder.setWeight(weight, weightUnitPreferene: preference)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyViewDelegate(userModelBuilder: builder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingWeightView_Navigate"
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
