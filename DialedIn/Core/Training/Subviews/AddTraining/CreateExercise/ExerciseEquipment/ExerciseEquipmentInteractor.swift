import SwiftUI

@MainActor
protocol ExerciseEquipmentInteractor: GlobalInteractor {
    var favouriteGymProfile: GymProfileModel? { get }
}

extension CoreInteractor: ExerciseEquipmentInteractor { }
