import SwiftUI

@MainActor
protocol GymProfileInteractor: GlobalInteractor {
    @discardableResult
    func updateGymProfile(profile: GymProfileModel, image: PlatformImage?) async throws -> GymProfileModel
}

extension CoreInteractor: GymProfileInteractor { }
