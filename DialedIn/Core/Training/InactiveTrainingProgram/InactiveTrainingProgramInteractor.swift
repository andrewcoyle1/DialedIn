import SwiftUI

@MainActor
protocol InactiveTrainingProgramInteractor: GlobalInteractor {
    var trainingPrograms: [TrainingProgram] { get }
}

extension CoreInteractor: InactiveTrainingProgramInteractor { }
