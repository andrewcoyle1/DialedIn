import SwiftUI

struct SetTrackerRowDelegate {
    var exercise: Binding<WorkoutExerciseModel>
    var set: Binding<WorkoutSetModel>
    let lastSet: WorkoutSetModel?
    var eventParameters: [String: Any]? {
        nil
    }
}

struct SetTrackerRowView: View {
    
    @State var presenter: SetTrackerRowPresenter
    let delegate: SetTrackerRowDelegate
    
    @FocusState private var isFocused: Bool
    @State private var textSelection: TextSelection?
    
    var body: some View {
        HStack {
            setNumber(set: delegate.set)
            Spacer()
            previousValues(exercise: delegate.exercise, set: delegate.set)
            Spacer()
            inputFields(exercise: delegate.exercise, set: delegate.set)
            Spacer()
            completeButton(exercise: delegate.exercise.wrappedValue, set: delegate.set)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                presenter.deleteSet(setId: delegate.set.id, exercise: delegate.exercise)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                presenter.onRestPickerRequested(setId: delegate.set.wrappedValue.id)
            } label: {
                Label("Rest Timer", systemImage: "timer")
            }
        }
        .moveDisabled(true)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    func setNumber(set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .center) {
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
                    .padding(8)
                    .background(set.wrappedValue.isWarmup ? Color.orange.opacity(0.2) : .secondary.opacity(0.05), in: .circle)
            }
        }
        .foregroundColor(.secondary)
        .frame(width: 28, alignment: .center)
    }

    func weightRepsFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        return HStack(spacing: 8) {
            weightTextField(exercise: exercise, set: set, unitPreference: unitPreference)
            repsField(exercise: exercise.wrappedValue, set: set)
        }
    }

    @ViewBuilder
    private func weightTextField(
        exercise: Binding<WorkoutExerciseModel>,
        set: Binding<WorkoutSetModel>,
        unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)
    ) -> some View {
        let weightBinding: Binding<Double?> = Binding<Double?>(
            get: {
                guard let kilograms = set.wrappedValue.weightKg else { return nil }
                return UnitConversion.convertWeight(kilograms, to: unitPreference.weightUnit)
                // Use trimming of trailing zeros for nicer display but keep as plain string
            },
            set: { newValue in
                guard let value = newValue else { return }
                let kilos = UnitConversion.convertWeightToKg(value, from: unitPreference.weightUnit)
                set.wrappedValue.weightKg = kilos
            }
        )
        AutoSelectNumberField(prompt: "-", value: weightBinding, keyboardType: .decimalPad)
            .frame(width: 70, height: 35)
    }

    @ViewBuilder
    private func repsField(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        let repsValue: Binding<Double?> = Binding<Double?>(
            get: {
                if let reps = set.wrappedValue.reps {
                    return Double(reps)
                } else {
                    return nil
                }
            },
            set: { newValue in
                if let newValue {
                    set.wrappedValue.reps = Int(newValue)
                } else {
                    set.wrappedValue.reps = nil
                }
            }
        )
        AutoSelectNumberField(prompt: "-", value: repsValue, keyboardType: .numberPad)
            .frame(width: 50, height: 35)
    }

    func previousValues(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        return VStack(alignment: .center) {
            if let prev = delegate.lastSet {
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
    func inputFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        switch exercise.wrappedValue.trackingMode {
        case .weightReps:
            weightRepsFields(exercise: exercise, set: set)
        case .repsOnly:
            repsField(exercise: exercise.wrappedValue, set: set)
        case .timeOnly:
            timeOnlyFields(exercise: exercise.wrappedValue, set: set)
        case .distanceTime:
            distanceTimeFields(exercise: exercise, set: set)
        }
    }

    func timeOnlyFields(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
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
    
    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
        }
    }

    func completeButton(exercise: WorkoutExerciseModel, set: Binding<WorkoutSetModel>) -> some View {
        Button {
            presenter.onSetComplete(exercise, set)
        } label: {
            Image(systemName: set.wrappedValue.completedAt != nil ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(
                    presenter.buttonColor(
                        set: set.wrappedValue,
                        canComplete: presenter.canComplete(
                            trackingMode: exercise.trackingMode,
                            set: set.wrappedValue
                        )
                    )
                )
                .frame(height: 35)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 32, alignment: .center)
        .disabled(!presenter.canComplete(trackingMode: exercise.trackingMode, set: set.wrappedValue))
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

    func distanceTimeFields(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>) -> some View {
        let unitPreference = presenter.getUnitPreference(for: exercise.wrappedValue)
        return HStack(spacing: 8) {
            distanceTimeDistanceField(exercise: exercise, set: set, unitPreference: unitPreference)
            distanceTimeTimeField(exercise: exercise, set: set)
        }
    }

    func distanceTimeDistanceField(exercise: Binding<WorkoutExerciseModel>, set: Binding<WorkoutSetModel>, unitPreference: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)) -> some View {
        VStack(alignment: .center, spacing: 2) {
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

}

#Preview {
    @Previewable @State var set: WorkoutSetModel = .mock
    @Previewable @State var exercise: WorkoutExerciseModel = .mock
    let lastSet: WorkoutSetModel? = .mock
    
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = SetTrackerRowDelegate(exercise: $exercise, set: $set, lastSet: lastSet)
    
    return RouterView { router in
        builder.setTrackerRowView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func setTrackerRowView(router: AnyRouter, delegate: SetTrackerRowDelegate) -> some View {
        SetTrackerRowView(
            presenter: SetTrackerRowPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSetTrackerRowView(delegate: SetTrackerRowDelegate) {
        router.showScreen(.push) { router in
            builder.setTrackerRowView(router: router, delegate: delegate)
        }
    }
    
}
