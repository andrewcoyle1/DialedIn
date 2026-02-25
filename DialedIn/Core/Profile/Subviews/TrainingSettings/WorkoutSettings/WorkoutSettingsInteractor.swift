import SwiftUI

@MainActor
protocol WorkoutSettingsInteractor: GlobalInteractor {
    var workoutSettings: WorkoutSettings { get }
    func saveWorkoutSettings(_ settings: WorkoutSettings)
}

extension CoreInteractor: WorkoutSettingsInteractor { }
