//
//  OnboardingHeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingHeightInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHeightInteractor { }

@MainActor
protocol OnboardingHeightRouter {
    func showDevSettingsView()
    func showOnboardingWeightView(delegate: OnboardingWeightViewDelegate)
}

extension CoreRouter: OnboardingHeightRouter { }

@Observable
@MainActor
class OnboardingHeightViewModel {
    private let interactor: OnboardingHeightInteractor
    private let router: OnboardingHeightRouter

    var unit: UnitOfLength = .centimeters
    var selectedCentimeters: Int = 175
    var selectedFeet: Int = 5
    var selectedInches: Int = 9

    // Computed properties to keep measurements synchronized
    private var heightInCentimeters: Int {
        selectedCentimeters
    }
    
    private var heightInFeet: Int {
        Int(Double(heightInCentimeters) / 30.48) // Convert cm to feet
    }
    
    private var heightInInches: Int {
        let totalInches = Int(Double(heightInCentimeters) / 2.54)
        return totalInches % 12 // Remaining inches after feet
    }
    
    var height: Double {
        switch unit {
        case .centimeters:
            return Double(heightInCentimeters)
        case .inches:
            return Double(heightInFeet) + Double(heightInInches) / 12.0
        }
    }
    
    var preference: LengthUnitPreference {
        switch unit {
        case .centimeters:
            return .centimeters
        case .inches:
            return .inches
        }
    }
    
    init(
        interactor: OnboardingHeightInteractor,
        router: OnboardingHeightRouter
    ) {
        self.interactor = interactor
        self.router = router

    }
    
    private var canSubmit: Bool {
        switch unit {
        case .centimeters:
            return (100...250).contains(selectedCentimeters)
        case .inches:
            return (3...8).contains(selectedFeet) && (0...11).contains(selectedInches)
        }
    }
    
    func navigateToWeightView(userBuilder: UserModelBuilder) {
        var builder = userBuilder
        builder.setHeight(Double(heightInCentimeters), lengthUnitPreference: preference)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingWeightView(delegate: OnboardingWeightViewDelegate(userModelBuilder: builder))
    }
    
    func updateImperialFromCentimeters() {
        let totalInches = Int(Double(selectedCentimeters) / 2.54)
        selectedFeet = totalInches / 12
        selectedInches = totalInches % 12
    }
    
    func updateCentimetersFromImperial() {
        let totalInches = (selectedFeet * 12) + selectedInches
        selectedCentimeters = Int(Double(totalInches) * 2.54)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingHeightView_Navigate"
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

enum UnitOfLength {
    case centimeters
    case inches
}
