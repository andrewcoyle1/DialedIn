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
            ForEach(delegate.exercise.sets) { set in
                let lastSet = delegate.lastExercise?.sets.first { previousSet in
                    previousSet.index == set.wrappedValue.index
                }
                setTrackerRow(
                    SetTrackerRowDelegate(
                        exercise: delegate.exercise,
                        set: set,
                        lastSet: lastSet
                    )
                )
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

    private var columnHeaders: some View {
        let unitPreference = presenter.getUnitPreference(for: delegate.exercise.wrappedValue)
        return HStack {
            Text("Set")
                .frame(width: 28, alignment: .center)
            Spacer()
            Text("Prev")
                .frame(width: 60, alignment: .center)
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
    
    private var addSetButton: some View {
        HStack {
            Image(systemName: "plus")
                .padding(4)
                .background(.secondary.opacity(0.05), in: .circle)
                .anyButton(.press) {
                    presenter.addSet(exercise: delegate.exercise)
                }
                .frame(width: 28, alignment: .center)
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
        onUpdateRestBefore: ((String, Int?) -> Void)? = nil
    ) -> some View {
        let presenter = SetTrackerPresenter(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self)
        )
        presenter.onUpdateRestBefore = onUpdateRestBefore
        return SetTrackerView(
            presenter: presenter,
            delegate: delegate,
            setTrackerRow: { delegate in
                self.setTrackerRowView(router: router, delegate: delegate)
            }
        )
    }
}
