import Foundation

struct WorkoutSettings: DataSyncModelProtocol {

    var id: String = "workout_settings"
    var authorId: String

    // MARK: - General
    var previousWorkoutReference: PreviousWorkoutReferenceOption = .anyWorkout
    var propagateChanges: Bool = false
    var rirTracking: Bool = false
    var supersetAutoScroll: Bool = true
    var exerciseAutoNext: Bool = true

    // MARK: - Display
    var keepAlive: Bool = true
    var showWorkoutTimer: Bool = true
    var showBodyweightContribution: Bool = false
    
    // MARK: - Warm-Up
    var addSmartWarmUps: Bool = true

    // MARK: - Rest Timer: Behaviour
    var useRestTimers: Bool = true
    var restAfterLastWarmUp: Bool = false
    var restBetweenExercises: Bool = true
    var restBetweenSideSets: Bool = false

    // MARK: - Rest Timer: Notifications
    var restTimerPlaySound: Bool = true
    var restTimerVibrate: Bool = true

    // MARK: - Rest Timer: Scaling
    var warmUpRestScaling: Double = 0.75
    var betweenExercisesRestScaling: Double = 1.0
    var sideSetRestScaling: Double = 0.5

    // MARK: - Rest Timer: Durations
    /// Per-exercise-type override durations (ExerciseType.rawValue → seconds).
    var restDurationsByExerciseType: [String: Int] = [:]
    /// Global default rest duration in seconds. Used by the workout tracker.
    var defaultRestDurationSeconds: Int = 90
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case keepAlive = "keep_alive"
        case showWorkoutTimer = "show_workout_timer"
        case showBodyweightContribution = "show_bodyweight_contribution"
        case exerciseAutoNext = "exercise_auto_next"
        case propagateChanges = "propagate_changes"
        case rirTracking = "rir_tracking"
        case addSmartWarmUps = "add_smart_warm_ups"
        case supersetAutoScroll = "superset_auto_scroll"
        case useRestTimers = "use_rest_timers"
        case restAfterLastWarmUp = "rest_after_last_warm_up"
        case restBetweenExercises = "rest_between_exercises"
        case restBetweenSideSets = "rest_between_side_sets"
        case restTimerPlaySound = "rest_timer_play_sound"
        case restTimerVibrate = "rest_timer_vibrate"
        case warmUpRestScaling = "warm_up_rest_scaling"
        case betweenExercisesRestScaling = "between_exercises_rest_scaling"
        case sideSetRestScaling = "side_set_rest_scaling"
        case restDurationsByExerciseType = "rest_durations_by_exercise_type"
        case defaultRestDurationSeconds = "default_rest_duration_seconds"
        case previousWorkoutReference = "previous_workout_reference"
    }
    
    var eventParameters: [String: Any] {
        [:]
    }
    
}

enum PreviousWorkoutReferenceOption: String, DataSyncModelProtocol {
    var id: String { self.rawValue }
    
    case anyWorkout
    case workoutsInProgram
    
    var title: String {
        switch self {
        case .anyWorkout:
            return "Any workout"
        case .workoutsInProgram:
            return "Workouts within program only"
        }
    }
    
    var subtitle: String {
        switch self {
        case .anyWorkout:
            return "Previous values for an exercise will display weight, reps, and RIR values from any workout that has previously included this exercise."
        case .workoutsInProgram:
            return "Previous values for an exercise will display weight, reps, and RIR values only from workouts within the same program."
        }
    }
}
