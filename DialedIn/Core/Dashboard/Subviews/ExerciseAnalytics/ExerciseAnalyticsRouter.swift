import SwiftUI

@MainActor
protocol ExerciseAnalyticsRouter: GlobalRouter {
    func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate)
}

extension CoreRouter: ExerciseAnalyticsRouter { }
