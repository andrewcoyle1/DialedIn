import SwiftUI

@MainActor
protocol ProgramDesignInteractor: GlobalInteractor {
    var userId: String? { get }
    var currentUser: UserModel? { get }
    func setActiveTrainingProgram(programId: String) async throws
    func createTrainingProgram(program: TrainingProgram) async throws
    func upsertTrainingProgram(program: TrainingProgram) async throws
    func readFavouriteGymProfile() async throws -> GymProfileModel
}

extension CoreInteractor: ProgramDesignInteractor { }
