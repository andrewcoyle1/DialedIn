//
//  PremiumAccess.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Foundation

/// The subscription gate every premium check in the app runs through.
///
/// `CoreInteractor.isPremium` used to return a hard-coded `true`, so nothing in a premium-only
/// app was actually gated. Restoring the entitlement check on its own would have made every
/// developer build demand an App Store subscription that a debug build cannot have — which is
/// presumably why it was stubbed, and why it would have been stubbed again. So the honest check
/// ships alongside a deliberate escape hatch rather than no check at all.
enum PremiumAccess {

    /// Whether the user should be treated as a subscriber.
    ///
    /// Deliberately a pure function of its two inputs rather than a read of ``PremiumOverride``:
    /// the unit-test target is not built with `-DDEV`, so the override branch would be compiled
    /// out of any test that tried to exercise it through the flag.
    static func isPremium(entitlements: [PurchasedEntitlement], developmentOverride: Bool) -> Bool {
        if developmentOverride {
            return true
        }

        return entitlements.hasActiveEntitlement
    }
}

/// The development-only input to ``PremiumAccess/isPremium(entitlements:developmentOverride:)``,
/// flipped from the "Simulate Premium" toggle in Developer Settings.
///
/// `DEV` arrives through `OTHER_SWIFT_FLAGS` on the app target's Debug configuration and `MOCK`
/// through the Mock configuration, so neither is defined for Release. In a shipping build the
/// storage key, the setter and the `UserDefaults` read are all absent from the binary and
/// `isEnabled` is a constant `false` — the override cannot be turned on by a defaults write, a
/// modified plist or a forgotten default, because there is nothing left to turn on.
@MainActor
enum PremiumOverride {

    #if DEV || MOCK
    static let storageKey = "dev_simulate_premium"

    /// Mock is the previews and UI-test configuration, where the whole app has to be reachable
    /// with no store behind it, so it starts on. A dev build talks to the real dev backend and
    /// starts honest, so the gate is what a developer sees unless they ask otherwise.
    #if MOCK
    private static let startingValue = true
    #else
    private static let startingValue = false
    #endif

    @UserDefault(key: storageKey, startingValue: startingValue)
    static var isEnabled: Bool
    #else
    static var isEnabled: Bool { false }
    #endif
}
