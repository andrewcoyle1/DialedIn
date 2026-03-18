//
//  WorkoutTrackerView+SetUI.swift
//  DialedIn
//
//  Extracted for function_body_length.
//

import SwiftUI

struct SetTrackerDelegate {
    let exercise: Binding<WorkoutExerciseModel>
    let lastExercise: WorkoutExerciseModel?
    var allWorkoutExercises: [WorkoutExerciseModel] = []
    var onSetSupersetGroup: @Sendable (String, String?) -> Void = { _, _ in }
    var onDeleteExercise: @Sendable () -> Void = { }
}

struct SetTrackerView<SetTrackerRow: View>: View {

    @State var presenter: SetTrackerPresenter
    let delegate: SetTrackerDelegate

    @ViewBuilder var setTrackerRow: (SetTrackerRowDelegate) -> SetTrackerRow
    
    var body: some View {
        Group {
            VStack {
                equipmentButton
                columnHeaders
            }
            ForEach(delegate.exercise.sets.filter { $0.wrappedValue.completedAt == nil || !$0.wrappedValue.isWarmup }) { set in
                let lastSet = delegate.lastExercise?.sets.first { previousSet in
                    previousSet.index == set.wrappedValue.index
                }
                setTrackerRow(
                    SetTrackerRowDelegate(
                        exercise: delegate.exercise,
                        set: set,
                        lastSet: lastSet,
                        showAutoRanges: presenter.showAutoRanges
                    )
                )
                .listRowSeparator(.visible)
            }
            addSetButton
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.vertical, 0)
        .listRowInsets(.leading, 0)
        .listSectionMargins(.top, 0)
    }
    
    private var equipmentButton: some View {
        ScrollView(.horizontal) {
            HStack {
                Group {
                    if !delegate.exercise.wrappedValue.equipmentVariations.isEmpty {
                        Button {
                            presenter.onExerciseEquipmentPressed(delegate.exercise)
                        } label: {
                            Label("Equipment", systemImage: "scalemass")
                        }
                    }

                    Button {
                        presenter.onWarmupSetsPressed(delegate.exercise)
                    } label: {
                        Label("Warmup", systemImage: "target")
                    }

                    Button {
                        presenter.onTargetsPressed(delegate.exercise)
                    } label: {
                        Label("Targets", systemImage: "scope")
                    }

                    Button {
                        presenter.onSwapPressed(delegate.exercise)
                    } label: {
                        Label("Swap", systemImage: "arrow.left.arrow.right")
                    }

                    Button {
                        presenter.onSupersetPressed(
                            exercise: delegate.exercise,
                            allWorkoutExercises: delegate.allWorkoutExercises,
                            onSetSupersetGroup: delegate.onSetSupersetGroup
                        )
                    } label: {
                        let groupLabel: String = {
                            guard let groupId = delegate.exercise.wrappedValue.supersetGroupId else { return "Superset" }
                            let count = delegate.allWorkoutExercises.filter { $0.supersetGroupId == groupId }.count
                            return count > 2 ? "Remove Circuit" : "Remove Superset"
                        }()
                        Label(groupLabel, systemImage: "arrow.2.circlepath")
                    }
                    Menu {
                        Button {
                            presenter.onExerciseSettingsPressed(exercise: delegate.exercise.wrappedValue)
                        } label: {
                            Label("Exercise Settings", systemImage: "slider.horizontal.3")
                        }
                        
                        Button(role: .destructive) {
                            presenter.deleteExercise(delegate.exercise, onDelete: delegate.onDeleteExercise)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .tint(.secondary)
                .buttonBorderShape(.capsule)
            }
        }
    }

    private var columnHeaders: some View {
        let unitPreference = presenter.getUnitPreference(for: delegate.exercise.wrappedValue)
        return HStack(alignment: .firstTextBaseline) {
            Text("Set")
                .frame(width: 34, alignment: .center)
            Spacer()
            prevAutoHeader(exercise: delegate.exercise)
            Spacer()
            HStack(spacing: 8) {
                unitMenu(exercise: delegate.exercise, unitPreference: unitPreference)
                    .frame(width: 70)
                Text("Reps")
                    .frame(width: 50)
            }
            Spacer()
            Text("Done")
                .frame(width: 32, alignment: .center)
        }
        .font(.caption2)
        .foregroundColor(.secondary)
        .padding(.top, 4)
    }
    
    private func prevAutoHeader(exercise: Binding<WorkoutExerciseModel>) -> some View {
        Button {
            presenter.showAutoRanges.toggle()
        } label: {
            if presenter.showAutoRanges {
                Label("Auto", systemImage: "wand.and.stars")
            } else {
                Label("Prev", systemImage: "arrow.left")
            }
        }
        .buttonStyle(.bordered)
        .font(.caption2)
        .foregroundColor(.secondary)
        .frame(width: 90, alignment: .center)
    }
    
    private var addSetButton: some View {
        HStack {
            Button {
                presenter.addSet(exercise: delegate.exercise)
            } label: {
                Image(systemName: "plus")
                    .font(.caption)
            }
            .tint(.secondary)
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .frame(width: 34, alignment: .center)
            Spacer()
        }
        
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
            Text(unitPreference.weightUnit.abbreviation.capitalized)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    @Previewable @State var exercise: WorkoutExerciseModel = .mock
    let lastExercise: WorkoutExerciseModel = .mock

    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = SetTrackerDelegate(
        exercise: $exercise,
        lastExercise: lastExercise
    )

    RouterView { router in
        List {
            DisclosureGroup(isExpanded: .constant(true)) {
                builder.setTrackerView(router: router, delegate: delegate)
            } label: {
                Text("Disclosure Group")
            }
        }
    }
}

extension CoreBuilder {
    func setTrackerView(
        router: AnyRouter,
        delegate: SetTrackerDelegate,
        onStartRest: ((Int) -> Void)? = nil
    ) -> some View {
        let presenter = SetTrackerPresenter(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self)
        )
        return SetTrackerView(
            presenter: presenter,
            delegate: delegate,
            setTrackerRow: { delegate in
                self.setTrackerRowView(router: router, delegate: delegate, onStartRest: onStartRest)
            }
        )
    }
}
