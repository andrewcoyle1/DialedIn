import SwiftUI

@MainActor
protocol ProgramDesignInteractor: GlobalInteractor {
    var userId: String? { get }
    var currentUser: UserModel? { get }
    var favouriteGymProfile: GymProfileModel? { get }
    var activeTrainingProgram: TrainingProgram? { get }
    func setActiveTrainingProgram(programId: String) async throws
    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws
    func saveWorkoutTemplate(workoutTemplate: WorkoutTemplateModel, image: PlatformImage?) async throws
}

extension CoreInteractor: ProgramDesignInteractor { }
