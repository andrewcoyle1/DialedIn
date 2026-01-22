import SwiftUI

@MainActor
protocol GymProfileInteractor {
    func updateGymProfile(profile: GymProfileModel) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: GymProfileInteractor { }
