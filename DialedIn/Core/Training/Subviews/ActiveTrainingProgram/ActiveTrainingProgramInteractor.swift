import SwiftUI

@MainActor
protocol ActiveTrainingProgramInteractor: GlobalInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    func deleteActiveSession() throws
    func deleteTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ActiveTrainingProgramInteractor { }
