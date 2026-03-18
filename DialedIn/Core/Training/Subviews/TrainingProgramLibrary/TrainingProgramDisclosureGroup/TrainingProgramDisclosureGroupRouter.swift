import SwiftUI

@MainActor
protocol TrainingProgramDisclosureGroupRouter: GlobalRouter {
    func showEditTrainingProgramView(delegate: EditTrainingProgramDelegate)
}

extension CoreRouter: TrainingProgramDisclosureGroupRouter { }
