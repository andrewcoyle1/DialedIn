import SwiftUI

@MainActor
protocol SetTrackerRowInteractor: GlobalInteractor {
    /// Load unit preferences for an exercise template.
    func getPreference(templateId: String) -> ExerciseUnitPreference
    var workoutSettings: WorkoutSettings { get }

    func startRest(
        durationSeconds: Int,
        session: WorkoutSessionModel,
        currentExerciseIndex: Int
    )
    /// Cancel any running rest timer.
    func cancelRest()

}

extension CoreInteractor: SetTrackerRowInteractor { }
