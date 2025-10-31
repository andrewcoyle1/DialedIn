//
//  OnboardingWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingWeightInteractor {
    func updateUserWeight(_ weight: Double, weightUnitPreference: WeightUnitPreference) throws
}

extension CoreInteractor: OnboardingWeightInteractor { }

@Observable
@MainActor
class OnboardingWeightViewModel {
    private let interactor: OnboardingWeightInteractor
        
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
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
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
    
    init(interactor: OnboardingWeightInteractor) {
        self.interactor = interactor
    }
    
    func navigateToExerciseFrequency(path: Binding<[OnboardingPathOption]>) {
        do {
            try interactor.updateUserWeight(weight, weightUnitPreference: preference)
            path.wrappedValue.append(.exerciseFrequency)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
