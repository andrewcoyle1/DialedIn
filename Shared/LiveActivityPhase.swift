//
//  LiveActivityPhase.swift
//  DialedIn
//
//  The phase model for the workout Live Activity (spec: docs/specs/live-activity.md §2).
//
//  Everything here lives in `Shared/` so the app target, the widget extension and the unit
//  tests all compile the same source. That means no app-only helpers: the formatting below
//  mirrors `UnitConversion.formatWeight` / `formatDistance` and the tracker's Prev column,
//  but is implemented locally rather than importing them.
//

import Foundation

// MARK: - Units

/// Weight unit for display, local to `Shared/` so this file does not depend on
/// `ExerciseWeightUnit` (app target only).
enum LiveActivityWeightUnit: String, Codable, Hashable, CaseIterable, Sendable {
    case kilograms
    case pounds

    var abbreviation: String {
        switch self {
        case .kilograms: return "kg"
        case .pounds: return "lb"
        }
    }

    /// Convert a stored kilogram value into this unit.
    func value(fromKilograms kilograms: Double) -> Double {
        switch self {
        case .kilograms: return kilograms
        case .pounds: return kilograms * 2.20462
        }
    }
}

// MARK: - Display values

/// The set the user is about to perform (or has just performed), formatted for the activity.
///
/// Named `LiveActivitySetTarget` because the app target already has a persisted
/// `SetTarget` model (`Managers/Training/Exercise/Models/SetTarget.swift`).
struct LiveActivitySetTarget: Equatable, Hashable, Sendable {
    var weightKg: Double?
    var reps: Int?
    var durationSec: Int?
    var distanceMeters: Double?

    init(weightKg: Double? = nil, reps: Int? = nil, durationSec: Int? = nil, distanceMeters: Double? = nil) {
        self.weightKg = weightKg
        self.reps = reps
        self.durationSec = durationSec
        self.distanceMeters = distanceMeters
    }

    /// True when every tracked value is nil, so there is nothing to show.
    var isEmpty: Bool {
        weightKg == nil && reps == nil && durationSec == nil && distanceMeters == nil
    }

    /// The four tracking shapes, in the same form as the tracker's Prev column:
    /// `60 kg × 8`, `12`, `1:30`, `400 m 10:00`. Nil pieces are omitted, and the whole
    /// label is `nil` when nothing is set.
    func label(weightUnit: LiveActivityWeightUnit) -> String? {
        var segments: [String] = []

        let weightText = weightKg.map { LiveActivityFormat.weight($0, unit: weightUnit) }
        let repsText = reps.map { String($0) }
        switch (weightText, repsText) {
        case let (weight?, reps?):
            segments.append("\(weight) × \(reps)")
        case let (weight?, nil):
            segments.append(weight)
        case let (nil, reps?):
            segments.append(reps)
        case (nil, nil):
            break
        }

        let distanceText = distanceMeters.map { LiveActivityFormat.distance($0) }
        let durationText = durationSec.map { LiveActivityFormat.duration($0) }
        switch (distanceText, durationText) {
        case let (distance?, duration?):
            segments.append("\(distance) \(duration)")
        case let (distance?, nil):
            segments.append(distance)
        case let (nil, duration?):
            segments.append(duration)
        case (nil, nil):
            break
        }

        return segments.isEmpty ? nil : segments.joined(separator: " ")
    }
}

/// "Set 2 of 4". `index` is 1-based.
struct SetPosition: Equatable, Hashable, Sendable {
    var index: Int
    var total: Int

    init(index: Int, total: Int) {
        self.index = index
        self.total = total
    }

    var label: String {
        "Set \(index) of \(total)"
    }
}

/// The set that was just logged, during whose rest the reps can still be corrected.
struct LoggedSet: Equatable, Hashable, Sendable {
    var setId: String
    var reps: Int?
    var weightKg: Double?

    init(setId: String, reps: Int? = nil, weightKg: Double? = nil) {
        self.setId = setId
        self.reps = reps
        self.weightKg = weightKg
    }

    /// The logged set rendered the same way a target is.
    func label(weightUnit: LiveActivityWeightUnit) -> String? {
        LiveActivitySetTarget(weightKg: weightKg, reps: reps).label(weightUnit: weightUnit)
    }
}

/// The end-of-workout figures. The workout name is on `WorkoutActivityAttributes`, not here.
struct Summary: Equatable, Hashable, Sendable {
    var durationSeconds: TimeInterval?
    var completedSetsCount: Int?
    var totalExercisesCount: Int?
    var volumeKg: Double?

    init(
        durationSeconds: TimeInterval? = nil,
        completedSetsCount: Int? = nil,
        totalExercisesCount: Int? = nil,
        volumeKg: Double? = nil
    ) {
        self.durationSeconds = durationSeconds
        self.completedSetsCount = completedSetsCount
        self.totalExercisesCount = totalExercisesCount
        self.volumeKg = volumeKg
    }
}

// MARK: - Formatting

/// Local mirrors of `UnitConversion`'s display formatting, so `Shared/` stays self-contained.
enum LiveActivityFormat {

    /// `60 kg`, `62.5 kg`, `132.3 lb` — one decimal, trimmed when it is zero.
    static func weight(_ kilograms: Double, unit: LiveActivityWeightUnit) -> String {
        let converted = unit.value(fromKilograms: kilograms)
        return "\(number(converted)) \(unit.abbreviation)"
    }

    /// `400 m`, or kilometres above 1000 m (`1.50 km`), matching `UnitConversion.formatDistance`.
    static func distance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }

    /// `1:30`, `10:00` — minutes and zero-padded seconds, as the tracker shows durations.
    static func duration(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        return "\(clamped / 60):\(String(format: "%02d", clamped % 60))"
    }

    private static func number(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return String(format: "%.0f", rounded)
        }
        return String(format: "%.1f", rounded)
    }
}

// MARK: - Phase

/// The eight layouts the Live Activity can be in. Derived once, in one place, from the
/// content state — the views branch on this and nothing else.
enum LiveActivityPhase: Equatable {
    /// About to lift.
    case ready(target: LiveActivitySetTarget, position: SetPosition)
    /// Countdown running.
    case resting(until: Date, next: LiveActivitySetTarget?, logged: LoggedSet?)
    /// Rest passed, phone untouched (or the activity has gone stale).
    case restOver(next: LiveActivitySetTarget)
    /// This exercise finished, more to come.
    case exerciseDone(next: String, firstTarget: LiveActivitySetTarget?)
    /// Nothing left but Finish.
    case allSetsDone
    /// `isActive == false`.
    case paused
    /// `isWorkoutEnded`.
    case ended(Summary)
    /// No exercise, no target. Renders like `.paused` without the label.
    case unknown
}

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

extension LiveActivityPhase {

    /// The only derivation. The precedence is spec §2, rows 1–8, in order.
    init(state: WorkoutActivityAttributes.ContentState, now: Date, isStale: Bool) {
        // 1. Ended beats everything.
        if state.isWorkoutEnded {
            self = .ended(
                Summary(
                    durationSeconds: state.finalDurationSeconds,
                    completedSetsCount: state.finalCompletedSetsCount,
                    totalExercisesCount: state.finalTotalExercisesCount,
                    volumeKg: state.finalVolumeKg
                )
            )
            return
        }

        // 2. Paused beats everything below it, including an in-flight rest.
        if !state.isActive {
            self = .paused
            return
        }

        // 3. Nothing left to do.
        if state.isAllSetsComplete {
            self = .allSetsDone
            return
        }

        self = Self.inProgressPhase(state: state, now: now, isStale: isStale)
    }

    /// Rows 4–8, once the three whole-workout states above have been ruled out.
    private static func inProgressPhase(
        state: WorkoutActivityAttributes.ContentState,
        now: Date,
        isStale: Bool
    ) -> LiveActivityPhase {
        let target = LiveActivitySetTarget(
            weightKg: state.targetWeightKg,
            reps: state.targetReps,
            durationSec: state.targetDurationSec,
            distanceMeters: state.targetDistanceMeters
        )

        if let restEndsAt = state.restEndsAt {
            // 4. Rest still running — and a stale activity cannot be trusted to be counting.
            if restEndsAt > now && !isStale {
                let logged = state.lastLoggedSetId.map {
                    LoggedSet(setId: $0, reps: state.lastLoggedReps, weightKg: state.lastLoggedWeightKg)
                }
                return .resting(until: restEndsAt, next: target.isEmpty ? nil : target, logged: logged)
            }
            // 5. Rest passed, or stale with a rest on the clock.
            return .restOver(next: target)
        }

        // 6. This exercise is finished and another one follows. Finished means every set is
        //    counted done and no row is left to tap: a half-finished left/right pair still has a
        //    target, so it stays on the banner rather than falling in here.
        if state.targetSetId == nil
            && state.currentExerciseCompletedSetsCount >= state.currentExerciseTotalSetsCount
            && state.currentExerciseIndex + 1 < state.totalExercisesCount {
            let nextTarget = LiveActivitySetTarget(
                weightKg: state.nextExerciseFirstTargetWeightKg,
                reps: state.nextExerciseFirstTargetReps,
                durationSec: state.nextExerciseFirstTargetDurationSec,
                distanceMeters: state.nextExerciseFirstTargetDistanceMeters
            )
            return .exerciseDone(
                next: state.nextExerciseName ?? "",
                firstTarget: nextTarget.isEmpty ? nil : nextTarget
            )
        }

        // 7. Ready to lift.
        if state.targetSetId != nil {
            return .ready(
                target: target,
                position: SetPosition(
                    index: state.currentExerciseCompletedSetsCount + 1,
                    total: state.currentExerciseTotalSetsCount
                )
            )
        }

        // 8. Nothing to show.
        return .unknown
    }
}

#endif
