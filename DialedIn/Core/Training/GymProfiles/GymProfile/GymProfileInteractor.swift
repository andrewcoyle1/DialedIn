import SwiftUI

@MainActor
protocol GymProfileInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: GymProfileInteractor { }
