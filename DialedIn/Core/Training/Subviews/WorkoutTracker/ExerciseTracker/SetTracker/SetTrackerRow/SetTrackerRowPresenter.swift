import SwiftUI

@Observable
@MainActor
class SetTrackerRowPresenter {
    
    private let interactor: SetTrackerRowInteractor
    private let router: SetTrackerRowRouter
    
    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0
    var restBeforeSetIdToSec: [String: Int] = [:]
    var onStartRest: ((Int) -> Void)?

    /// Handed the set that was just logged. Smart progression uses it to re-suggest the sets of
    /// this exercise that are still to come.
    var onSetCompleted: (@MainActor (WorkoutSetModel, WorkoutExerciseModel) -> Void)?

    var previousLookup: [PreviousSetKey: WorkoutSetModel] = [:]
    var defaultRestDurationSeconds: Int {
        interactor.workoutSettings.defaultRestDurationSeconds
    }

    init(interactor: SetTrackerRowInteractor, router: SetTrackerRowRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: SetTrackerRowDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: SetTrackerRowDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    /// A left set and its right partner are one set, so swiping either away removes both — a
    /// surviving half would number and rest as a set of its own.
    func deleteSet(setId: String, exercise: Binding<WorkoutExerciseModel>) {
        let removing = Set(exercise.wrappedValue.sets.pairedSetIds(for: setId))
        guard !removing.isEmpty else { return }
        exercise.wrappedValue.sets.removeAll(where: { removing.contains($0.id) })
    }
    
    func onSetComplete(_ exercise: WorkoutExerciseModel, _ set: Binding<WorkoutSetModel>) {
        if set.wrappedValue.completedAt == nil, validateSetData(trackingMode: exercise.trackingMode, set: set.wrappedValue) {
            set.wrappedValue.completedAt = Date()
            let useRestTimers = interactor.workoutSettings.useRestTimers
            let duration = restAfterCompleting(set.wrappedValue, in: exercise)
            interactor.trackEvent(event: Event.setCompleted(
                setId: set.wrappedValue.id,
                exerciseId: exercise.id,
                useRestTimers: useRestTimers,
                restDurationSeconds: duration ?? 0,
                onStartRestIsNil: onStartRest == nil
            ))
            if useRestTimers, let duration {
                onStartRest?(duration)
            }
            // Off by default. With it on, finishing a set re-suggests the ones still to come.
            if interactor.workoutSettings.smartProgressionApplyInSession {
                onSetCompleted?(set.wrappedValue, exercise)
            }
        } else {
            set.wrappedValue.completedAt = nil
        }
    }

    /// How long to rest after this set, or `nil` when the settings say not to rest here at all.
    ///
    /// A rest set by hand on the set wins outright and unscaled: the user typed that number for
    /// that set and meant it. Everything else starts from the base below and is then scaled by
    /// where the set sits in the exercise, because the four moments are not the same rest — a
    /// warm-up is a ramp, the gap between the two limbs of one set is the time it takes to swap
    /// hands, the gap after the last set is the walk to the next exercise, and the gap between
    /// sets is the one that actually needs to be long.
    func restAfterCompleting(_ set: WorkoutSetModel, in exercise: WorkoutExerciseModel) -> Int? {
        if let custom = restBeforeSetIdToSec[set.id] {
            return custom
        }

        let settings = interactor.workoutSettings
        let base = baseRestDuration(for: exercise)

        if set.isWarmup {
            // The last warm-up runs straight into the first working set unless asked otherwise,
            // which is the whole point of warming up.
            if isLastWarmup(set, in: exercise), !settings.restAfterLastWarmUp {
                return nil
            }
            return scale(base, by: settings.warmUpRestScaling)
        }

        // Before the last-set check, because the left half of a pair is never the last working
        // set and would otherwise fall through to the full between-sets rest.
        if hasFollowingSidePartner(set, in: exercise) {
            guard settings.restBetweenSideSets else { return nil }
            return scale(base, by: settings.sideSetRestScaling)
        }

        if isLastWorkingSet(set, in: exercise) {
            guard settings.restBetweenExercises else { return nil }
            return scale(base, by: settings.betweenExercisesRestScaling)
        }

        return base
    }

    /// The unscaled rest for this exercise, narrowest setting first: the rest set on this one
    /// exercise, then the one set for its whole type, then the global default.
    ///
    /// A zero-second override is treated as no override at all. Both screens that write it clear
    /// to `nil` on an empty picker, but a document written by an older build can still carry a
    /// literal zero, and resting for no time is not something a user can have meant.
    private func baseRestDuration(for exercise: WorkoutExerciseModel) -> Int {
        if let exerciseDuration = interactor.exerciseRestOverride(for: exercise.templateId), exerciseDuration > 0 {
            return exerciseDuration
        }
        if let exerciseType = interactor.allExercises.first(where: { $0.id == exercise.templateId })?.type,
           let typeDuration = interactor.workoutSettings.restDurationsByExerciseType[exerciseType.rawValue] {
            return typeDuration
        }
        return interactor.workoutSettings.defaultRestDurationSeconds
    }

    /// Scaling to nothing means no rest rather than a zero-second one.
    private func scale(_ base: Int, by factor: Double) -> Int? {
        let scaled = Int((Double(base) * factor).rounded())
        return scaled > 0 ? scaled : nil
    }

    /// True when this set is the first limb of a pair whose other limb is still to come, so what
    /// follows is a swap of hands rather than a rest between sets.
    private func hasFollowingSidePartner(_ set: WorkoutSetModel, in exercise: WorkoutExerciseModel) -> Bool {
        set.side == .left && exercise.sets.pairedSetIds(for: set.id).count == 2
    }

    private func isLastWarmup(_ set: WorkoutSetModel, in exercise: WorkoutExerciseModel) -> Bool {
        exercise.sets.last(where: { $0.isWarmup })?.id == set.id
    }

    /// Warm-ups are prepended, so the last working set is the last of the sets that are not one.
    private func isLastWorkingSet(_ set: WorkoutSetModel, in exercise: WorkoutExerciseModel) -> Bool {
        exercise.sets.last(where: { !$0.isWarmup })?.id == set.id
    }

    func onRestPickerRequested(exercise: WorkoutExerciseModel, setId: String) {
        restPickerTargetSetId = setId
        // Open on the rest that would actually run for this set, scaling included. A rest already
        // set by hand is keyed by id alone, so it is honoured whether or not the set is among the
        // ones passed in. Where the settings say no rest runs here, offer the unscaled base
        // instead — the user opening the picker plainly wants a rest, and there is nothing else to
        // show them.
        let existing = restBeforeSetIdToSec[setId]
            ?? exercise.sets.first(where: { $0.id == setId })
                .flatMap { restAfterCompleting($0, in: exercise) }
            ?? baseRestDuration(for: exercise)
        restPickerMinutesSelection = existing / 60
        restPickerSecondsSelection = existing % 60

        router.showRestModal(
            primaryButtonAction: { [weak self] in
                guard let self else { return }
                let total = (self.restPickerMinutesSelection * 60) + self.restPickerSecondsSelection
                let seconds = total > 0 ? total : nil
                self.updateRestBefore(setId: setId, seconds: seconds)
                self.router.dismissModal()
            },
            secondaryButtonAction: { [weak self] in self?.router.dismissModal() },
            minutesSelection: Binding(
                get: { self.restPickerMinutesSelection },
                set: { self.restPickerMinutesSelection = $0 }
            ),
            secondsSelection: Binding(
                get: { self.restPickerSecondsSelection },
                set: { self.restPickerSecondsSelection = $0 }
            )
        )
    }

    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }

    func onWarmupSetHelpPressed() {
        router.showWarmupSetInfoModal {
            self.router.dismissModal()
        }
    }

    func getUnitPreference(for exercise: WorkoutExerciseModel) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        let templateId: String = exercise.templateId
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = interactor.getPreference(templateId: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
    }

    func validateSetData(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            if let weight = set.weightKg, weight < 0 {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
                return false
            }
            guard let reps = set.reps, reps > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
                return false
            }
            return true
        case .repsOnly:
            guard let reps = set.reps, reps > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
                return false
            }
            return true
        case .timeOnly:
            guard let duration = set.durationSec, duration > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
                return false
            }
            return true
        case .distanceTime:
            guard let distance = set.distanceMeters, distance > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
                return false
            }
            guard let duration = set.durationSec, duration > 0 else {
                router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
                return false
            }
            return true
        }
    }

    func canComplete(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps
        case .repsOnly:
            return set.reps != nil && set.reps! > 0
        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0
        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }

    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .secondary.opacity(0.3)
        }
    }
}

extension SetTrackerRowPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: SetTrackerRowDelegate)
        case onDisappear(delegate: SetTrackerRowDelegate)
        case setCompleted(setId: String, exerciseId: String, useRestTimers: Bool, restDurationSeconds: Int, onStartRestIsNil: Bool)

        var eventName: String {
            switch self {
            case .onAppear:                 return "SetTrackerRowView_Appear"
            case .onDisappear:              return "SetTrackerRowView_Disappear"
            case .setCompleted:             return "SetTrackerRow_SetCompleted"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .setCompleted(let setId, let exerciseId, let useRestTimers, let restDurationSeconds, let onStartRestIsNil):
                return [
                    "set_id": setId,
                    "exercise_id": exerciseId,
                    "use_rest_timers": useRestTimers,
                    "rest_duration_seconds": restDurationSeconds,
                    "on_start_rest_is_nil": onStartRestIsNil
                ]
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
