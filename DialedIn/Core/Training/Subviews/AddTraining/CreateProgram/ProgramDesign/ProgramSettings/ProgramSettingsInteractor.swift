import SwiftUI

@MainActor
protocol ProgramSettingsInteractor: GlobalInteractor {
    func upsertTrainingProgram(program: TrainingProgram) async throws
    func setActiveTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ProgramSettingsInteractor { }
