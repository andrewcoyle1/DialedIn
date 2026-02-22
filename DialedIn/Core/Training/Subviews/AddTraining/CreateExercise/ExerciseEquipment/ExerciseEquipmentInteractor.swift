import SwiftUI

@MainActor
protocol ExerciseEquipmentInteractor: GlobalInteractor {
    func readFavouriteGymProfile() async throws -> GymProfileModel
}

extension CoreInteractor: ExerciseEquipmentInteractor { }
