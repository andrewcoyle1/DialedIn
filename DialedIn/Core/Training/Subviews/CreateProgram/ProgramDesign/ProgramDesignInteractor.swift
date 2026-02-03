import SwiftUI

@MainActor
protocol ProgramDesignInteractor {
    var userId: String? { get }
    func setActiveTrainingProgram(programId: String) async throws
    func createTrainingProgram(program: TrainingProgram) async throws
    func upsertTrainingProgram(program: TrainingProgram) async throws
    func readFavouriteGymProfile() async throws -> GymProfileModel
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramDesignInteractor { }
