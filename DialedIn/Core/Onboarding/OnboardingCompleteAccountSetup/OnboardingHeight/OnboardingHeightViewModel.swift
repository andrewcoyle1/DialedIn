//
//  OnboardingHeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingHeightInteractor {
    func updateHeight(_ height: Double, lengthUnitPreference: LengthUnitPreference) throws
}

extension CoreInteractor: OnboardingHeightInteractor { }

@Observable
@MainActor
class OnboardingHeightViewModel {
    private let interactor: OnboardingHeightInteractor
    
    var unit: UnitOfLength = .centimeters
    var selectedCentimeters: Int = 175
    var selectedFeet: Int = 5
    var selectedInches: Int = 9
    
    var showAlert: AnyAppAlert?
    
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
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif

    init(interactor: OnboardingHeightInteractor) {
        self.interactor = interactor
    }
    
    private var canSubmit: Bool {
        switch unit {
        case .centimeters:
            return (100...250).contains(selectedCentimeters)
        case .inches:
            return (3...8).contains(selectedFeet) && (0...11).contains(selectedInches)
        }
    }
    
    func navigateToWeightView(path: Binding<[OnboardingPathOption]>) {
        do {
            try interactor.updateHeight(height, lengthUnitPreference: preference)
            path.wrappedValue.append(.weight)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
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
}

enum UnitOfLength {
    case centimeters
    case inches
}
