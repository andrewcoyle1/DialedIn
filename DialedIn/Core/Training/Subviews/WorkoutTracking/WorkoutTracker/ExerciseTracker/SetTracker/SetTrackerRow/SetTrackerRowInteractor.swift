import SwiftUI

@MainActor
protocol SetTrackerRowInteractor: GlobalInteractor {
    /// Load unit preferences for an exercise template.
    func getPreference(templateId: String) -> ExerciseUnitPreference
    var workoutSettings: WorkoutSettings { get }
    var allExercises: [ExerciseModel] { get }
}

extension CoreInteractor: SetTrackerRowInteractor { }
