import SwiftUI

@MainActor
protocol ExerciseEquipmentInteractor {
    func trackEvent(event: LoggableEvent)
    func readFavouriteGymProfile() async throws -> GymProfileModel
}

extension CoreInteractor: ExerciseEquipmentInteractor { }
