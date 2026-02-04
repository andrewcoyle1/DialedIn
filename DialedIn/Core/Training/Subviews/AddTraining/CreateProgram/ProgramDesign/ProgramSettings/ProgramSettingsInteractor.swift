import SwiftUI

@MainActor
protocol ProgramSettingsInteractor {
    func trackEvent(event: LoggableEvent)
    func setActiveTrainingProgram(programId: String) async throws
}

extension CoreInteractor: ProgramSettingsInteractor { }
