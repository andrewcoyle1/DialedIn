import SwiftUI

@MainActor
protocol RestTimerSettingsInteractor: GlobalInteractor {
    var workoutSettings: WorkoutSettings { get }
    func saveWorkoutSettings(_ settings: WorkoutSettings)
}

extension CoreInteractor: RestTimerSettingsInteractor { }
