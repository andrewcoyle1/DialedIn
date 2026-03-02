//
//  SetTrackerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

import SwiftUI

@Observable
@MainActor
class SetTrackerPresenter {
    private let interactor: SetTrackerInteractor
    private let router: SetTrackerRouter

    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]
    var previousWorkoutSession: WorkoutSessionModel?
    var previousLookup: [Int: WorkoutSetModel] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0
    var restBeforeSetIdToSec: [String: Int] = [:]

    var defaultRestDurationSeconds: Int {
        interactor.workoutSettings.defaultRestDurationSeconds
    }

    var userId: String? {
        interactor.userId
    }
    
    init(interactor: SetTrackerInteractor, router: SetTrackerRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onExerciseEquipmentPressed(_ exercise: Binding<WorkoutExerciseModel>) {
        let delegate = WorkoutExerciseEquipmentSheetDelegate(exercise: exercise) { resistance, support in
            exercise.wrappedValue.chosenResistanceEquipment = resistance
            exercise.wrappedValue.chosenSupportEquipment = support
        }
        router.showWorkoutExerciseEquipmentSheetView(delegate: delegate)
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

    func deleteSet(setId: String, exercise: Binding<WorkoutExerciseModel>) {
        exercise.wrappedValue.sets.removeAll(where: { $0.id == setId })
    }

    func addSet(exercise: Binding<WorkoutExerciseModel>) {
        guard let userId = interactor.userId else { return }
        let existingSets = exercise.wrappedValue.sets
        let newIndex = existingSets.count + 1
        let lastSet = existingSets.last

        let newSet = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: userId,
            index: newIndex,
            reps: lastSet?.reps,
            weightKg: lastSet?.weightKg,
            durationSec: lastSet?.durationSec,
            distanceMeters: lastSet?.distanceMeters,
            rpe: lastSet?.rpe,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        )

        exercise.wrappedValue.sets.append(newSet)
    }

    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }

    func onRestPickerRequested(setId: String) {
        restPickerTargetSetId = setId
        let existing = restBeforeSetIdToSec[setId] ?? defaultRestDurationSeconds
        restPickerMinutesSelection = existing / 60
        restPickerSecondsSelection = existing % 60

        router.showRestModal(
            primaryButtonAction: { [weak self] in
                guard let self else { return }
                let total = (self.restPickerMinutesSelection * 60) + self.restPickerSecondsSelection
                self.updateRestBefore(setId: setId, seconds: total > 0 ? total : nil)
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

    func onWarmupSetHelpPressed() {
        router.showWarmupSetInfoModal {
            self.router.dismissModal()
        }
    }

    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
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

    func updateWeightUnit(_ unit: ExerciseWeightUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let templateId: String = exercise.wrappedValue.templateId
        var current = getUnitPreference(for: exercise.wrappedValue)
        current.weightUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setWeightUnit(unit, for: templateId)
    }

    func convertAndRoundWeights(to newUnit: ExerciseWeightUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let currentUnit = getUnitPreference(for: exercise.wrappedValue).weightUnit

        for set in exercise.sets {
            guard let weightKg = set.wrappedValue.weightKg else { continue }
            let weightInNewUnit = UnitConversion.convertWeight(weightKg, from: currentUnit, into: newUnit)
            let weightKgAsNewUnit = UnitConversion.convertWeightToKg(weightInNewUnit, from: newUnit)

            let roundedWeightKg = WorkoutSessionModel.roundWeightToEquipmentIncrement(
                weightKg: weightKgAsNewUnit,
                workoutExercise: exercise.wrappedValue,
                gymProfile: interactor.favouriteGymProfile,
                preferredWeightUnit: newUnit
            )

            let roundedWeightKgFinal: Double
            if roundedWeightKg == weightKgAsNewUnit {
                let roundedWeight: Double
                if newUnit == .kilograms {
                    roundedWeight = round(weightInNewUnit * 2) / 2.0
                } else {
                    roundedWeight = round(weightInNewUnit)
                }
                roundedWeightKgFinal = UnitConversion.convertWeightToKg(roundedWeight, from: newUnit)
            } else {
                roundedWeightKgFinal = roundedWeightKg
            }

            set.wrappedValue.weightKg = roundedWeightKgFinal
        }

    }

    /// Shows a prompt asking whether to just change display unit or convert values
    func promptWeightUnitChange(_ newUnit: ExerciseWeightUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let currentUnit = getUnitPreference(for: exercise.wrappedValue).weightUnit
        guard newUnit != currentUnit else { return }

        router.showAlert(
            title: "Change Weight Unit",
            subtitle: "How would you like to change the unit for '\(exercise.wrappedValue.name)'?",
            buttons: {
                AnyView(
                    VStack(spacing: 8) {
                        Button("Display Only") {
                            self.updateWeightUnit(newUnit, for: exercise)
                        }
                        Button("Convert Values") {
                            self.convertAndRoundWeights(to: newUnit, for: exercise)
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }

    /// Shows a prompt asking whether to just change display unit or convert values
    func promptDistanceUnitChange(_ newUnit: ExerciseDistanceUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let currentUnit = getUnitPreference(for: exercise.wrappedValue).distanceUnit
        guard newUnit != currentUnit else { return }

        router.showAlert(
            title: "Change Distance Unit",
            subtitle: "How would you like to change the unit for '\(exercise.wrappedValue.name)'?",
            buttons: {
                AnyView(
                    VStack(spacing: 8) {
                        Button("Display Only") {
                            self.updateDistanceUnit(newUnit, for: exercise)
                        }
                        Button("Convert Values") {
                            self.convertAndRoundDistances(to: newUnit, for: exercise)
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }

    func convertAndRoundDistances(to newUnit: ExerciseDistanceUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let currentUnit = getUnitPreference(for: exercise.wrappedValue).distanceUnit

        for set in exercise.sets {
            guard let distanceMeters = set.wrappedValue.distanceMeters else { continue }
            let distanceInNewUnit = UnitConversion.convertDistance(distanceMeters, from: currentUnit, into: newUnit)
            let roundedDistance: Double
            if newUnit == .meters {
                roundedDistance = round(distanceInNewUnit)
            } else {
                roundedDistance = round(distanceInNewUnit * 100) / 100.0
            }
            set.wrappedValue.distanceMeters = UnitConversion.convertDistanceToMeters(roundedDistance, from: newUnit)
        }
        updateDistanceUnit(newUnit, for: exercise)
    }

    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for exercise: Binding<WorkoutExerciseModel>) {
        let templateId: String = exercise.wrappedValue.templateId
        var current = getUnitPreference(for: exercise.wrappedValue)
        current.distanceUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setDistanceUnit(unit, for: templateId)
    }

    func buildPreviousLookup(for exercise: WorkoutExerciseModel) -> [Int: WorkoutSetModel] {
        guard let prevSession = previousWorkoutSession else { return [:] }
        
        // Find matching exercise by templateId
        guard let prevExercise = prevSession.exercises.first(where: { $0.templateId == exercise.templateId }) else {
            return [:]
        }
        
        // Map sets by index
        return Dictionary(uniqueKeysWithValues: prevExercise.sets.map { ($0.index, $0) })
    }

}
