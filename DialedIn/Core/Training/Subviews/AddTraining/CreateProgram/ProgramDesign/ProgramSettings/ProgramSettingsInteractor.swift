import SwiftUI

@MainActor
protocol ProgramSettingsInteractor: GlobalInteractor {
    func saveTrainingProgram(trainingProgram: TrainingProgram) async throws
    func setActiveTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ProgramSettingsInteractor { }
