//
//  WorkoutExerciseEquipmentSheetInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/02/2026.
//

@MainActor
protocol WorkoutExerciseEquipmentSheetInteractor {
    var userId: String? { get }
    var favouriteGymProfile: GymProfileModel? { get }
    func getExerciseTemplate(id: String) async throws -> ExerciseModel
}

extension CoreInteractor: WorkoutExerciseEquipmentSheetInteractor { }
