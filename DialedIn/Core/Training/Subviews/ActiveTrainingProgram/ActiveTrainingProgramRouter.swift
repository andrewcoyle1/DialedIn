import SwiftUI

@MainActor
protocol ActiveTrainingProgramRouter: GlobalRouter {
    func showEditTrainingProgramView(delegate: EditTrainingProgramDelegate)
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showWorkoutTrackerView()
}

extension CoreRouter: ActiveTrainingProgramRouter { }
