//
//  OnboardingTargetWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingTargetWeightInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTargetWeightInteractor { }

@MainActor
protocol OnboardingTargetWeightRouter {
    func showDevSettingsView()
    func showOnboardingWeightRateView(delegate: OnboardingWeightRateViewDelegate)
}

extension CoreRouter: OnboardingTargetWeightRouter { }

@Observable
@MainActor
class OnboardingTargetWeightViewModel {
    private let interactor: OnboardingTargetWeightInteractor
    private let router: OnboardingTargetWeightRouter

    let isStandaloneMode: Bool
    
    var targetWeight: Double = 0
    var currentWeight: Double = 0
    var weightUnit: WeightUnitPreference = .kilograms
    var selectedKilograms: Int = 0
    var selectedPounds: Int = 0
    var didInitialize: Bool = false
    
    init(
        interactor: OnboardingTargetWeightInteractor,
        router: OnboardingTargetWeightRouter,
        isStandaloneMode: Bool = false
    ) {
        self.interactor = interactor
        self.router = router
        self.isStandaloneMode = isStandaloneMode
    }
    
    var canContinue: Bool {
        targetWeight != 0 && targetWeight != currentWeight
    }

    // MARK: - Ranges
    func kilogramRange(weightGoalBuilder: WeightGoalBuilder) -> ClosedRange<Int> {
        let base = Int((interactor.currentUser?.weightKilograms ?? 0).rounded())
        // Provide sensible global bounds
        let minKg = 30
        let maxKg = 200
        switch weightGoalBuilder.objective {
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

    func poundRange(weightGoalBuilder: WeightGoalBuilder) -> ClosedRange<Int> {
        // Convert kg range to lb bounds for parity
        let minLb = 66
        let maxLb = 440
        let baseLb = Int(((interactor.currentUser?.weightKilograms ?? 0) * 2.20462).rounded())
        switch weightGoalBuilder.objective {
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
    
    func onAppear(weightGoalBuilder: WeightGoalBuilder) {

        // Initialise user weight and correct unit
        let user = interactor.currentUser
        let fallbackKg = 70
        let currentKg = max(1, Int(user?.weightKilograms ?? 0))

        currentWeight = user?.weightKilograms ?? Double(fallbackKg)
        weightUnit = user?.weightUnitPreference ?? .kilograms

        // Initialize ranges and selections respecting objective
        switch weightUnit {
        case .kilograms:
            let initial = currentKg > 0 ? currentKg : fallbackKg
            selectedKilograms = clamp(initial: initial, within: kilogramRange(weightGoalBuilder: weightGoalBuilder))
            updateFromKilograms()
        case .pounds:
            let currentLb = max(1, Int((user?.weightKilograms ?? 0) * 2.20462))
            let fallbackLb = Int((Double(fallbackKg) * 2.20462).rounded())
            let initial = currentLb > 0 ? currentLb : fallbackLb
            selectedPounds = clamp(initial: initial, within: poundRange(weightGoalBuilder: weightGoalBuilder))
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
    
    func navigateToWeightRate(weightGoalBuilder: WeightGoalBuilder) {
        var builder = weightGoalBuilder
        builder.setTargetWeight(targetWeight)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingWeightRateView(delegate: OnboardingWeightRateViewDelegate(weightGoalBuilder: builder))
    }
    
    private func clamp(initial: Int, within range: ClosedRange<Int>) -> Int {
        return min(max(initial, range.lowerBound), range.upperBound)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TargetWeight_Navigate"
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
