//
//  WorkoutTrackerView+SetUI.swift
//  DialedIn
//
//  Extracted for function_body_length.
//

import SwiftUI

struct SetTrackerDelegate {
    let exercise: Binding<WorkoutExerciseModel>
//    let workoutSession: Binding<WorkoutSessionModel>
//    let previousLookup: [Int: WorkoutSetModel]
//    let onUpdateSet: (WorkoutSetModel, String) -> Void
//    let restBeforeSetIdToSec: [String: Int]
//    let defaultRestDurationSeconds: Int
//    let onUpdateRestBefore: (String, Int?) -> Void
}

struct SetTrackerView: View {

    @State var presenter: SetTrackerPresenter
    let delegate: SetTrackerDelegate

    var body: some View {
        Group {
            equipmentButton(delegate.exercise.wrappedValue)
            setsList(delegate.exercise)
            addSetButton(delegate.exercise)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
        .listSectionMargins(.top, 0)
    }

    @ViewBuilder
    private func equipmentButton(_ exercise: WorkoutExerciseModel) -> some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    presenter.onExerciseEquipmentPressed(delegate.exercise)
                } label: {
                    Label("Equipment", systemImage: "scalemass")
                        .padding(4)
                        .padding(.horizontal, 4)
                        .background(Color.secondary.opacity(0.3), in: .capsule)
                }
            }
        }
    }

    @ViewBuilder
    private func setsList(_ exercise: Binding<WorkoutExerciseModel>) -> some View {
        ForEach(exercise.sets) { set in
            setRow(exercise: exercise, set: set)
        }
    }

    @ViewBuilder
    private func setRow(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        VStack {
            HStack {
                setNumber(set: set)
                Spacer()
                previousValues(exercise: exercise, set: set)
                Spacer()
                inputFields(exercise: exercise, set: set)
                Spacer()
                completeButton(exercise: exercise.wrappedValue, set: set)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                presenter.deleteSet(setId: set.id, exercise: delegate.exercise)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                presenter.onRestPickerRequested(setId: set.wrappedValue.id)
            } label: {
                Label("Rest Timer", systemImage: "timer")
            }
        }
        .moveDisabled(true)
    }

    func previousValues(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        let previousSet = presenter.previousLookup[set.wrappedValue.index]
        return VStack(alignment: .center) {
            if set.wrappedValue.index == 1 {
                Text("Prev")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if let prev = previousSet {
                previousValueContent(trackingMode: exercise.wrappedValue.trackingMode, prev: prev, unitPreference: unitPreference)
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

    func setNumber(set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .center) {
            if set.wrappedValue.index == 1 {
                Text("Set")
                    .font(.caption2)
            }
            Menu {
                Button {
                    set.wrappedValue.isWarmup.toggle()
                } label: {
                    Label("Warmup Set", systemImage: set.wrappedValue.isWarmup ? "checkmark" : "")
                }

                Button {
                    presenter.onWarmupSetHelpPressed()
                } label: {
                    Label("What's a warmup set?", systemImage: "info.circle")
                }
            } label: {
                Text("\(set.wrappedValue.index)")
                    .font(.subheadline)
                    .frame(height: 35)
                    .frame(width: 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(set.wrappedValue.isWarmup ? Color.orange.opacity(0.2) : .secondary.opacity(0.05))
                    )
            }
        }
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private func addSetButton(_ exercise: Binding<WorkoutExerciseModel>) -> some View {
        Button {
            presenter.addSet(exercise: exercise)
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Set")
            }
            .font(.footnote.bold())
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.accent.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
    }

    @ViewBuilder
    private func unitMenu(exercise: Binding<WorkoutExerciseModel>, unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)) -> some View {
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
            Text(unitPreference.weightUnit.abbreviation)
                .autocapitalization(.words)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func weightRepsFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        return HStack(spacing: 8) {
            weightField(exercise: exercise, set: set, unitPreference: unitPreference)
            repsField(exercise: exercise.wrappedValue, set: set)
        }
    }

    @ViewBuilder
    private func weightField(
        exercise: Binding<WorkoutExerciseModel>,
        set: Binding<WorkoutSetModel>,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        VStack(alignment: .center) {
            if set.wrappedValue.index == 1 {
                unitMenu(exercise: exercise, unitPreference: unitPreference)
            }
            weightTextField(exercise: exercise, set: set, unitPreference: unitPreference)
        }
        .frame(width: 70)
    }

    @ViewBuilder
    private func weightTextField(
        exercise: Binding<WorkoutExerciseModel>,
        set: Binding<WorkoutSetModel>,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        TextField("0", value: Binding(
            get: {
                guard let kilograms = set.wrappedValue.weightKg else { return nil }
                return UnitConversion.convertWeight(kilograms, to: unitPreference.weightUnit)
            },
            set: { newValue in
                guard let value = newValue else {
                    set.wrappedValue.weightKg = nil
                    return
                }
                let kilos = UnitConversion.convertWeightToKg(value, from: unitPreference.weightUnit)
                set.wrappedValue.weightKg = kilos
            }
        ), format: .number)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.decimalPad)
        .frame(height: 35)
    }

    @ViewBuilder
    private func repsField(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .leading) {
            if set.wrappedValue.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: set.reps, format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: 35)
        }
        .frame(width: 50)
    }

    @ViewBuilder
    func inputFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        switch exercise.wrappedValue.trackingMode {
        case .weightReps:
            weightRepsFields(exercise: exercise, set: set)
        case .repsOnly:
            repsOnlyFields(exercise: exercise.wrappedValue, set: set)
        case .timeOnly:
            timeOnlyFields(exercise: exercise.wrappedValue, set: set)
        case .distanceTime:
            distanceTimeFields(exercise: exercise, set: set)
        }
    }

    func repsOnlyFields(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .leading) {
            if set.wrappedValue.index == 1 {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            TextField("0", value: set.reps, format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .frame(height: 35)
        }
        .frame(width: 60)
    }

    func timeOnlyFields(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if set.wrappedValue.index == 1 {
                Text("Duration")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 4) {
                TextField("0", value: Binding(
                    get: { set.wrappedValue.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (set.wrappedValue.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            set.wrappedValue.durationSec = newDuration
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 40)

                Text(":")
                    .font(.caption)

                TextField("00", value: Binding(
                    get: { set.wrappedValue.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (set.wrappedValue.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            set.wrappedValue.durationSec = newDuration
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

    func distanceTimeFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        return HStack(spacing: 8) {
            distanceTimeDistanceField(exercise: exercise, set: set, unitPreference: unitPreference)
            distanceTimeTimeField(exercise: exercise, set: set)
        }
    }

    func distanceTimeDistanceField(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>, unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)) -> some View {
        VStack(alignment: .center, spacing: 2) {
            if set.wrappedValue.index == 1 {
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
                    guard let meters = set.wrappedValue.distanceMeters else { return nil }
                    return UnitConversion.convertDistance(meters, to: unitPreference.distanceUnit)
                },
                set: { newValue in
                    guard let value = newValue else {
                        set.wrappedValue.distanceMeters = nil
                        return
                    }
                    let meters = UnitConversion.convertDistanceToMeters(value, from: unitPreference.distanceUnit)
                    set.wrappedValue.distanceMeters = meters
                }
            ), format: .number)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .frame(height: 35)
        }
        .frame(width: 70)
    }

    func distanceTimeTimeField(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if set.wrappedValue.index == 1 {
                Text("Time")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 2) {
                TextField("0", value: Binding(
                    get: { set.wrappedValue.durationSec.map { $0 / 60 } },
                    set: { newMinutes in
                        if let minutes = newMinutes {
                            let seconds = (set.wrappedValue.durationSec ?? 0) % 60
                            let newDuration = minutes * 60 + seconds
                            set.wrappedValue.durationSec = newDuration
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 35)
                Text(":")
                    .font(.caption2)
                TextField("00", value: Binding(
                    get: { set.wrappedValue.durationSec.map { $0 % 60 } },
                    set: { newSeconds in
                        if let seconds = newSeconds {
                            let minutes = (set.wrappedValue.durationSec ?? 0) / 60
                            let newDuration = minutes * 60 + seconds
                            set.wrappedValue.durationSec = newDuration
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

    func completeButton(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        Button {
            if set.wrappedValue.completedAt == nil {
                if presenter.validateSetData(trackingMode: exercise.trackingMode, set: set.wrappedValue) {
                    set.wrappedValue.completedAt = Date()
                }
            } else {
                set.wrappedValue.completedAt = nil
            }
        } label: {
            VStack(alignment: .center) {
                if set.wrappedValue.index == 1 {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: set.wrappedValue.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(presenter.buttonColor(set: set.wrappedValue, canComplete: presenter.canComplete(trackingMode: exercise.trackingMode, set: set.wrappedValue)))
                    .frame(height: 35)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .center)
    }

}

#Preview {
    @Previewable @State var exercise: WorkoutExerciseModel = .mock
    @Previewable @State var session: WorkoutSessionModel = .mock
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = SetTrackerDelegate(exercise: $exercise)

    RouterView { router in
        builder.setTrackerView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func setTrackerView(router: AnyRouter, delegate: SetTrackerDelegate) -> some View {
        SetTrackerView(
            presenter: SetTrackerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}
