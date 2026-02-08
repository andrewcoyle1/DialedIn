import SwiftUI

@MainActor
protocol ProgramSettingsInteractor {
    func trackEvent(event: LoggableEvent)
    func upsertTrainingProgram(program: TrainingProgram) async throws
    func setActiveTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ProgramSettingsInteractor { }
