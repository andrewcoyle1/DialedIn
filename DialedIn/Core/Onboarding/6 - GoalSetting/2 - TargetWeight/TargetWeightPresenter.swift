//
//  TargetWeightPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TargetWeightPresenter {
    private let interactor: TargetWeightInteractor
    private let router: TargetWeightRouter

    let isStandaloneMode: Bool
    
    var targetWeight: Double = 0
    var currentWeight: Double = 0
    var weightUnit: WeightUnitPreference = .kilograms
    var selectedKilograms: Int = 0
    var selectedPounds: Int = 0
    var didInitialize: Bool = false
    
    init(
        interactor: TargetWeightInteractor,
        router: TargetWeightRouter,
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

    /// The user's own weight, as a number the wheel arithmetic can survive.
    ///
    /// Both wheels turn this into an `Int`, and `Int(_:)` traps on a value that is not finite.
    /// The weight is a plain `Double` off a Firestore document, so a corrupt or half-written
    /// profile carries the trap with it — and both ranges are read from the view body, so it
    /// would fire as the screen drew. A missing weight already reads as zero here, and every
    /// branch below has a fallback for that, so zero is the honest answer for an unusable one too.
    private var currentWeightKilograms: Double {
        (interactor.currentUser?.submittedWeightKilograms ?? 0)
            .clamped(to: 0...Self.heaviestPlausibleKilograms, whenNotFinite: 0)
    }

    /// Far above the top of either wheel. It exists so the conversion cannot overflow, not to
    /// express an opinion about anybody's weight.
    private static let heaviestPlausibleKilograms: Double = 1_000

    func kilogramRange(delegate: TargetWeightDelegate) -> ClosedRange<Int> {
        let weight = currentWeightKilograms
        // The bound that faces the user's own weight rounds *away* from the objective, so a whole
        // number on the wheel is never on the wrong side of a fractional weight. Rounding both
        // ways alike offered someone at 72.6 kg who chose "lose weight" a target of 73 — a goal
        // to gain, which every calorie target downstream would have honoured as written.
        let floorKg = Int(weight.rounded(.down))
        let ceilKg = Int(weight.rounded(.up))
        // Provide sensible global bounds
        let minKg = 30
        let maxKg = 200
        switch delegate.overarchingObjective {
        case .gainWeight:
            let lower = max(minKg, ceilKg > 0 ? ceilKg : minKg)
            return min(lower, maxKg)...maxKg
        case .loseWeight:
            let upper = min(maxKg, floorKg > 0 ? floorKg : maxKg)
            return minKg...max(upper, minKg)
        case .maintain:
            // allow +/- 10kg window
            let base = Int(weight.rounded())
            let lower = max(minKg, (base > 0 ? base - 10 : 70))
            let upper = min(maxKg, (base > 0 ? base + 10 : 90))
            return lower...max(upper, lower)
        }
    }

    func poundRange(delegate: TargetWeightDelegate) -> ClosedRange<Int> {
        // Convert kg range to lb bounds for parity
        let minLb = 66
        let maxLb = 440
        let weightLb = UnitConversion.kgToLbs(currentWeightKilograms)
        // Rounded away from the objective, for the reason given on `kilogramRange` — and the
        // conversion makes a fractional pound figure out of almost every stored weight, so this
        // wheel is where a whole-number bound lands on the wrong side most often.
        let floorLb = Int(weightLb.rounded(.down))
        let ceilLb = Int(weightLb.rounded(.up))
        switch delegate.overarchingObjective {
        case .gainWeight:
            let lower = max(minLb, ceilLb > 0 ? ceilLb : minLb)
            return min(lower, maxLb)...maxLb
        case .loseWeight:
            let upper = min(maxLb, floorLb > 0 ? floorLb : maxLb)
            return minLb...max(upper, minLb)
        case .maintain:
            let baseLb = Int(weightLb.rounded())
            let lower = max(minLb, (baseLb > 0 ? baseLb - 22 : 154 - 22)) // ~10kg
            let upper = min(maxLb, (baseLb > 0 ? baseLb + 22 : 154 + 22))
            return lower...max(upper, lower)
        }
    }

    // MARK: - Updates
    
    func onAppear(delegate: TargetWeightDelegate) {

        // Initialise user weight and correct unit
        let user = interactor.currentUser
        let fallbackKg = 70
        // `max(1, Int(weight))` would not have helped: the trap is inside the conversion, which
        // runs before the floor is ever applied.
        let weight = currentWeightKilograms
        let currentKg = max(1, Int(weight))

        currentWeight = user?.submittedWeightKilograms.flatMap { $0.isFinite ? $0 : nil } ?? Double(fallbackKg)
        weightUnit = user?.submittedWeightUnitPreference ?? .kilograms

        // Initialize ranges and selections respecting objective
        switch weightUnit {
        case .kilograms:
            let initial = currentKg > 0 ? currentKg : fallbackKg
            selectedKilograms = clamp(initial: initial, within: kilogramRange(delegate: delegate))
            updateFromKilograms()
        case .pounds:
            let currentLb = max(1, Int(UnitConversion.kgToLbs(weight)))
            let fallbackLb = Int(UnitConversion.kgToLbs(Double(fallbackKg)).rounded())
            let initial = currentLb > 0 ? currentLb : fallbackLb
            selectedPounds = clamp(initial: initial, within: poundRange(delegate: delegate))
            updateFromPounds()
        }
        didInitialize = true
    }
    func updateFromKilograms() {
        targetWeight = Double(selectedKilograms)
        selectedPounds = Int(UnitConversion.kgToLbs(targetWeight).rounded())
    }
    
    func updateFromPounds() {
        targetWeight = UnitConversion.lbsToKg(Double(selectedPounds))
        selectedKilograms = Int(targetWeight.rounded())
    }
    
    func onContinuePressed(delegate: TargetWeightDelegate) {
        let delegate = WeightRateDelegate(delegate: delegate, targetWeight: targetWeight)
        interactor.trackEvent(event: Event.navigate)
        router.showWeightRateView(delegate: delegate)
    }
    
    private func clamp(initial: Int, within range: ClosedRange<Int>) -> Int {
        return min(max(initial, range.lowerBound), range.upperBound)
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

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
