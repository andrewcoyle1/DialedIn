//
//  WorkoutTrackerView+ExerciseUI.swift
//  DialedIn
//
//  Extracted for type_body_length and file_length.
//

import SwiftUI

// MARK: - Exercise & Set UI (extracted from WorkoutTrackerView)
extension WorkoutTrackerView {

    @ViewBuilder
    func exerciseTracker(_ exercise: WorkoutExerciseModel) -> some View {
        DisclosureGroup {
            setsContent(exercise)
                .listRowSpacing(0)
        } label: {
            exerciseHeader(exercise)
        }
    }

    @ViewBuilder
    func exerciseHeader(_ exercise: WorkoutExerciseModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text("Set \(exercise.completedSetsCount)/\(exercise.sets.count)")
                    .font(.caption)
                    .foregroundColor(exercise.completedSetsCount == exercise.sets.count ? .green : .secondary)
            }
            Spacer()
        }
        .tappableBackground()
        .listRowInsets(.vertical, .zero)
    }

    func setNumber(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .center) {
            if set.index == 1 {
                Text("Set")
                    .font(.caption2)
            }
            Menu {
                Button {
                    updateSetValue(set, in: exercise.id) { $0.isWarmup.toggle() }
                } label: {
                    Label("Warmup Set", systemImage: set.isWarmup ? "checkmark" : "")
                }

                Button {
                    presenter.onWarmupSetHelpPressed()
                } label: {
                    Label("What's a warmup set?", systemImage: "info.circle")
                }
            } label: {
                Text("\(set.index)")
                    .font(.subheadline)
                    .frame(height: 35)
                    .frame(width: 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(set.isWarmup ? Color.orange.opacity(0.2) : .secondary.opacity(0.05))
                    )
            }
        }
        .foregroundColor(.secondary)
    }

    func previousValues(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        let previousSet = presenter.buildPreviousLookup(for: exercise)[set.index]
        return VStack(alignment: .center) {
            if set.index == 1 {
                Text("Prev")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if let prev = previousSet {
                previousValueContent(trackingMode: exercise.trackingMode, prev: prev, unitPreference: unitPreference)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
        .frame(width: 60, alignment: .center)
    }

    @ViewBuilder
    func previousValueContent(
        trackingMode: TrackingMode,
        prev: WorkoutSetModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        switch trackingMode {
        case .weightReps:
            previousValueWeightReps(prev: prev, unitPreference: unitPreference)
        case .repsOnly:
            previousValueRepsOnly(prev: prev)
        case .timeOnly:
            previousValueTimeOnly(prev: prev)
        case .distanceTime:
            previousValueDistanceTime(prev: prev, unitPreference: unitPreference)
        }
    }

    func previousValueWeightReps(
        prev: WorkoutSetModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        Group {
            if let weight = prev.weightKg, let reps = prev.reps {
                let displayWeight = UnitConversion.formatWeight(weight, unit: unitPreference.weightUnit)
                Text("\(displayWeight) × \(reps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
    }

    func previousValueRepsOnly(prev: WorkoutSetModel) -> some View {
        Group {
            if let reps = prev.reps {
                Text("\(reps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
    }

    func previousValueTimeOnly(prev: WorkoutSetModel) -> some View {
        Group {
            if let duration = prev.durationSec {
                let minutes = duration / 60
                let seconds = duration % 60
                Text("\(minutes):\(String(format: "%02d", seconds))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
    }

    func previousValueDistanceTime(
        prev: WorkoutSetModel,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        Group {
            if let distance = prev.distanceMeters, let duration = prev.durationSec {
                let displayDistance = UnitConversion.formatDistance(distance, unit: unitPreference.distanceUnit)
                let minutes = duration / 60
                let seconds = duration % 60
                Text("\(displayDistance) \(minutes):\(String(format: "%02d", seconds))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
                    .lineLimit(2)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 35)
            }
        }
    }

    @ViewBuilder
    func inputFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        switch exercise.trackingMode {
        case .weightReps:
            weightRepsFields(exercise: exercise, set: set)
        case .repsOnly:
            repsOnlyFields(exercise: exercise, set: set)
        case .timeOnly:
            timeOnlyFields(exercise: exercise, set: set)
        case .distanceTime:
            distanceTimeFields(exercise: exercise, set: set)
        }
    }

    func repsOnlyFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading) {
            if set.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: Binding(
                get: { set.reps },
                set: { newValue in
                    updateSetValue(set, in: exercise.id) { $0.reps = newValue }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: 35)
        }
        .frame(width: 60)
    }

    func timeOnlyFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if set.index == 1 {
                Text("Duration")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 4) {
                TextField("0", value: Binding(
                    get: { set.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (set.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)

                Text(":")
                    .font(.caption)

                TextField("00", value: Binding(
                    get: { set.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (set.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)
            }
            .frame(width: 90)
            .frame(height: 35)
        }
    }

    func distanceTimeFields(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        return HStack(spacing: 8) {
            distanceTimeDistanceField(exercise: exercise, set: set, unitPreference: unitPreference)
            distanceTimeTimeField(exercise: exercise, set: set)
        }
    }

    func distanceTimeDistanceField(exercise: WorkoutExerciseModel, set: WorkoutSetModel, unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)) -> some View {
        VStack(alignment: .center, spacing: 2) {
            if set.index == 1 {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            presenter.promptDistanceUnitChange(unit, for: exercise)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == unitPreference.distanceUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text(unitPreference.distanceUnit.abbreviation)
                        .autocapitalization(.words)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            TextField("0", value: Binding(
                get: {
                    guard let meters = set.distanceMeters else { return nil }
                    return UnitConversion.convertDistance(meters, to: unitPreference.distanceUnit)
                },
                set: { newValue in
                    updateSetValue(set, in: exercise.id) { updated in
                        guard let value = newValue else {
                            updated.distanceMeters = nil
                            return
                        }
                        let meters = UnitConversion.convertDistanceToMeters(value, from: unitPreference.distanceUnit)
                        updated.distanceMeters = meters
                    }
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .frame(height: 35)
        }
        .frame(width: 70)
    }

    func distanceTimeTimeField(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if set.index == 1 {
                Text("Time")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 2) {
                TextField("0", value: Binding(
                    get: { set.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (set.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 35)
                Text(":")
                    .font(.caption2)
                TextField("00", value: Binding(
                    get: { set.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (set.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            updateSetValue(set, in: exercise.id) { $0.durationSec = newDuration }
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 35)
            }
            .frame(height: 35)
        }
        .frame(width: 80)
    }

    func completeButton(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        Button {
            if set.completedAt == nil {
                if presenter.validateSetData(trackingMode: exercise.trackingMode, set: set) {
                    updateSetValue(set, in: exercise.id) { $0.completedAt = Date() }
                }
            } else {
                updateSetValue(set, in: exercise.id) { $0.completedAt = nil }
            }
        } label: {
            VStack(alignment: .center) {
                if set.index == 1 {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: set.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(presenter.buttonColor(set: set, canComplete: presenter.canComplete(trackingMode: exercise.trackingMode, set: set)))
                    .frame(height: 35)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .center)
    }

    func restSelector(exercise: WorkoutExerciseModel, set: WorkoutSetModel) -> some View {
        Button {
            presenter.onRestPickerRequested(setId: set.id)
        } label: {
            HStack {
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                Image(systemName: "timer")
                Text(presenter.restBeforeSetIdToSec[set.id].map { "\($0)s" } ?? "Rest")
                    .fontWeight(.medium)
                Capsule()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
            }
        }
    }

    func updateSetValue(
        _ set: WorkoutSetModel,
        in exerciseId: String,
        update: (inout WorkoutSetModel) -> Void
    ) {
        var updated = set
        update(&updated)
        presenter.updateSet(updated, in: exerciseId)
    }

    @ViewBuilder
    func unitPreferenceMenu(_ exercise: WorkoutExerciseModel) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.templateId)
        
        Menu {
            if exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
                            presenter.promptWeightUnitChange(unit, for: exercise)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == unitPreference.weightUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Weight Unit", systemImage: "scalemass")
                }
            }

            if exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            presenter.promptDistanceUnitChange(unit, for: exercise)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == unitPreference.distanceUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Distance Unit", systemImage: "ruler")
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }
}
