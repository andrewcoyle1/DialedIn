import SwiftUI

@MainActor
protocol ProgramDesignInteractor {
    var userId: String? { get }
    func setActiveTrainingProgram(programId: String) async throws
    func createTrainingProgram(program: TrainingProgram) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProgramDesignInteractor { }
