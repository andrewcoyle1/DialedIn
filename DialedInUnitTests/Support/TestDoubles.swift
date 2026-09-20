//
//  TestDoubles.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 20/09/2026.
//

import Foundation
import SwiftUI
import SwiftfulRouting
@testable import DialedIn

/// Scaffolding for testing presenters.
///
/// A presenter takes an interactor and a router, both screen-specific protocols that `CoreInteractor`
/// and `CoreRouter` conform to. Neither of those can be built in a test — `CoreRouter` needs a live
/// `AnyRouter` from the view hierarchy — so each screen gets a small double instead.
///
/// `GlobalRouter` only requires one property, `router: AnyRouter`, and SwiftfulRouting publishes a
/// mock one through `RouterEnvironmentKey.defaultValue`. That is what makes this cheap: a router
/// double is its navigation methods recording what they were asked to do, and nothing else.

/// The mock `AnyRouter` the package uses for previews. Navigating through it does nothing.
@MainActor
enum TestRouting {
    static var anyRouter: AnyRouter { RouterEnvironmentKey.defaultValue }
}

/// Records the analytics and haptics every interactor inherits, so a test can assert a screen
/// logged what it should without a `LogManager`.
@MainActor
class SpyGlobalInteractor: GlobalInteractor {
    private(set) var trackedEventNames: [String] = []
    private(set) var trackedScreenEventNames: [String] = []
    private(set) var playedHaptics: [HapticOption] = []

    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        trackedEventNames.append(eventName)
    }

    func trackEvent(event: AnyLoggableEvent) {
        trackedEventNames.append(event.eventName)
    }

    func trackEvent(event: LoggableEvent) {
        trackedEventNames.append(event.eventName)
    }

    func trackScreenEvent(event: LoggableEvent) {
        trackedScreenEventNames.append(event.eventName)
    }

    func playHaptic(option: HapticOption) {
        playedHaptics.append(option)
    }
}
