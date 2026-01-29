import SwiftUI

@MainActor
protocol GymProfileInteractor {
    @discardableResult
    func updateGymProfile(profile: GymProfileModel, image: PlatformImage?) async throws -> GymProfileModel
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: GymProfileInteractor { }
