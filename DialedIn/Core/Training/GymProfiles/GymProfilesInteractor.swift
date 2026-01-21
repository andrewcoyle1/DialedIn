import SwiftUI

@MainActor
protocol GymProfilesInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: GymProfilesInteractor { }
