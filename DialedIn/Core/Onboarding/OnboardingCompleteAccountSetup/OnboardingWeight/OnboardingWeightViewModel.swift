//
//  OnboardingWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingWeightInteractor {
    
}

extension CoreInteractor: OnboardingWeightInteractor { }

@Observable
@MainActor
class OnboardingWeightViewModel {
    private let interactor: OnboardingWeightInteractor
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let lengthUnitPreference: LengthUnitPreference
    
    var unit: UnitOfWeight = .kilograms
    var selectedKilograms: Int = 70
    var selectedPounds: Int = 154
    var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case exerciseFrequency(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
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
    
    init(
        interactor: OnboardingWeightInteractor,
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        lengthUnitPreference: LengthUnitPreference
    ) {
        self.interactor = interactor
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.lengthUnitPreference = lengthUnitPreference
    }
    
    func navigateToExerciseFrequency(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.exerciseFrequency(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: preference))
    }
}
