//
//  OnboardingTargetWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingTargetWeightInteractor {
    var currentUser: UserModel? { get }
}

extension CoreInteractor: OnboardingTargetWeightInteractor { }

@Observable
@MainActor
class OnboardingTargetWeightViewModel {
    private let interactor: OnboardingTargetWeightInteractor
    
    let objective: OverarchingObjective
    let isStandaloneMode: Bool
    
    var targetWeight: Double = 0
    var currentWeight: Double = 0
    var weightUnit: WeightUnitPreference = .kilograms
    var selectedKilograms: Int = 0
    var selectedPounds: Int = 0
    var didInitialize: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingTargetWeightInteractor,
        objective: OverarchingObjective,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.objective = objective
        self.isStandaloneMode = isStandaloneMode
    }
    
    var canContinue: Bool {
        targetWeight != 0 && targetWeight != currentWeight
    }

    // MARK: - Ranges
    var kilogramRange: ClosedRange<Int> {
        let base = Int((interactor.currentUser?.weightKilograms ?? 0).rounded())
        // Provide sensible global bounds
        let minKg = 30
        let maxKg = 200
        switch objective {
        case .gainWeight:
            let lower = max(minKg, base > 0 ? base : minKg)
            return lower...maxKg
        case .loseWeight:
            let upper = min(maxKg, base > 0 ? base : maxKg)
            return minKg...max(upper, minKg)
        case .maintain:
            // allow +/- 10kg window
            let lower = max(minKg, (base > 0 ? base - 10 : 70))
            let upper = min(maxKg, (base > 0 ? base + 10 : 90))
            return lower...upper
        }
    }

    var poundRange: ClosedRange<Int> {
        // Convert kg range to lb bounds for parity
        let minLb = 66
        let maxLb = 440
        let baseLb = Int(((interactor.currentUser?.weightKilograms ?? 0) * 2.20462).rounded())
        switch objective {
        case .gainWeight:
            let lower = max(minLb, baseLb > 0 ? baseLb : minLb)
            return lower...maxLb
        case .loseWeight:
            let upper = min(maxLb, baseLb > 0 ? baseLb : maxLb)
            return minLb...max(upper, minLb)
        case .maintain:
            let lower = max(minLb, (baseLb > 0 ? baseLb - 22 : 154 - 22)) // ~10kg
            let upper = min(maxLb, (baseLb > 0 ? baseLb + 22 : 154 + 22))
            return lower...upper
        }
    }

    // MARK: - Updates
    
    func onAppear() {
        let user = interactor.currentUser
        let fallbackKg = 70
        let currentKg = max(1, Int(user?.weightKilograms ?? 0))

        currentWeight = user?.weightKilograms ?? Double(fallbackKg)
        weightUnit = user?.weightUnitPreference ?? .kilograms
        // Initialize ranges and selections respecting objective
        switch weightUnit {
        case .kilograms:
            let initial = currentKg > 0 ? currentKg : fallbackKg
            selectedKilograms = clamp(initial: initial, within: kilogramRange)
            updateFromKilograms()
        case .pounds:
            let currentLb = max(1, Int((user?.weightKilograms ?? 0) * 2.20462))
            let fallbackLb = Int((Double(fallbackKg) * 2.20462).rounded())
            let initial = currentLb > 0 ? currentLb : fallbackLb
            selectedPounds = clamp(initial: initial, within: poundRange)
            updateFromPounds()
        }
        didInitialize = true
    }
    func updateFromKilograms() {
        targetWeight = Double(selectedKilograms)
        selectedPounds = Int((targetWeight * 2.20462).rounded())
    }
    
    func updateFromPounds() {
        targetWeight = Double(selectedPounds) / 2.20462
        selectedKilograms = Int(targetWeight.rounded())
    }
    
    private func clamp(initial: Int, within range: ClosedRange<Int>) -> Int {
        return min(max(initial, range.lowerBound), range.upperBound)
    }
}
