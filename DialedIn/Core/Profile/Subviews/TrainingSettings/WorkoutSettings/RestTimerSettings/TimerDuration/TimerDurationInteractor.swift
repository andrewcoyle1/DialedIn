import SwiftUI

@MainActor
protocol TimerDurationInteractor: GlobalInteractor {
    var workoutSettings: WorkoutSettings { get }
    func saveWorkoutSettings(_ workoutSettings: WorkoutSettings) async throws
}

extension CoreInteractor: TimerDurationInteractor { }
