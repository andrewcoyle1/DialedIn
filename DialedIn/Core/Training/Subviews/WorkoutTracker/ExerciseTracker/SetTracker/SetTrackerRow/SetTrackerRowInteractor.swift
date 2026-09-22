import SwiftUI

@MainActor
protocol SetTrackerRowInteractor: GlobalInteractor {
    /// Load unit preferences for an exercise template.
    func getPreference(templateId: String) -> ExerciseUnitPreference
    var workoutSettings: WorkoutSettings { get }
    var allExercises: [ExerciseModel] { get }
    /// The rest this one exercise was given on its own settings screen, if any.
    func exerciseRestOverride(for exerciseId: String) -> Int?
}

extension CoreInteractor: SetTrackerRowInteractor { }
