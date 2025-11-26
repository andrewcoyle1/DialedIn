//
//  ExerciseTrackerCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI
import CustomRouting

struct ExerciseTrackerCardViewDelegate {
    var exercise: WorkoutExerciseModel
    var exerciseIndex: Int
    var isCurrentExercise: Bool
    var weightUnit: ExerciseWeightUnit
    var distanceUnit: ExerciseDistanceUnit
    var previousSetsByIndex: [Int: WorkoutSetModel]
    var onSetUpdate: (WorkoutSetModel) -> Void
    var onAddSet: () -> Void
    var onDeleteSet: (String) -> Void
    var onHeaderLongPress: () -> Void
    var onNotesChange: (String) -> Void
    var onWeightUnitChange: (ExerciseWeightUnit) -> Void
    var onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
    var restBeforeSecForSet: (String) -> Int?
    var onRestBeforeChange: (String, Int?) -> Void
    var onRequestRestPicker: (String, Int?) -> Void
    var getLatestExercise: () -> WorkoutExerciseModel?
    var getLatestExerciseIndex: () -> Int
    var getLatestIsCurrentExercise: () -> Bool
    var getLatestWeightUnit: () -> ExerciseWeightUnit
    var getLatestDistanceUnit: () -> ExerciseDistanceUnit
    var getLatestPreviousSets: () -> [Int: WorkoutSetModel]
    var isExpanded: Binding<Bool>
}

struct ExerciseTrackerCardView: View {

    @State var viewModel: ExerciseTrackerCardViewModel
    
    var delegate: ExerciseTrackerCardViewDelegate

    @ViewBuilder var setTrackerRowView: (SetTrackerRowViewDelegate) -> AnyView

    init(delegate: ExerciseTrackerCardViewDelegate, interactor: ExerciseTrackerCardInteractor, setTrackerRowView: @escaping (SetTrackerRowViewDelegate) -> AnyView) {
        self.delegate = delegate
        _viewModel = State(wrappedValue: ExerciseTrackerCardViewModel(
            interactor: interactor,
            exercise: delegate.exercise,
            exerciseIndex: delegate.exerciseIndex,
            isCurrentExercise: delegate.isCurrentExercise,
            weightUnit: delegate.weightUnit,
            distanceUnit: delegate.distanceUnit,
            previousSetsByIndex: delegate.previousSetsByIndex
        ))
        self.setTrackerRowView = setTrackerRowView
    }

    var body: some View {
        DisclosureGroup(isExpanded: delegate.isExpanded) {
            setsContent
        } label: {
            exerciseHeader
        }
        .onChange(of: delegate.isExpanded.wrappedValue) { _, newValue in
            if newValue {
                // Refresh exercise data when card expands
                let latestExercise = delegate.getLatestExercise() ?? viewModel.exercise
                let latestExerciseIndex = delegate.getLatestExerciseIndex()
                let latestIsCurrentExercise = delegate.getLatestIsCurrentExercise()
                let latestWeightUnit = delegate.getLatestWeightUnit()
                let latestDistanceUnit = delegate.getLatestDistanceUnit()
                let latestPreviousSets = delegate.getLatestPreviousSets()
                
                viewModel.refresh(
                    with: latestExercise,
                    exerciseIndex: latestExerciseIndex,
                    isCurrentExercise: latestIsCurrentExercise,
                    weightUnit: latestWeightUnit,
                    distanceUnit: latestDistanceUnit,
                    previousSetsByIndex: latestPreviousSets
                )
            }
        }
    }
    
    private var exerciseHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(viewModel.exerciseIndex + 1).")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.exercise.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Text("\(viewModel.completedSetsCount)/\(viewModel.exercise.sets.count) sets")
                .font(.caption)
                .foregroundColor(viewModel.completedSetsCount == viewModel.exercise.sets.count ? .green : .secondary)
            
            Spacer()
            
            // Unit preference menu
            unitPreferenceMenu
        }
        .tappableBackground()
        .onLongPressGesture(minimumDuration: 0.4) {
            delegate.onHeaderLongPress()
        }
        .listRowInsets(.vertical, .zero)
    }
    
    @ViewBuilder
    private var unitPreferenceMenu: some View {
        Menu {
            // Show weight options for exercises that track weight
            if viewModel.exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
                            delegate.onWeightUnitChange(unit)
                            viewModel.weightUnit = unit
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == viewModel.weightUnit {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Weight Unit", systemImage: "scalemass")
                }
            }
            
            // Show distance options for exercises that track distance
            if viewModel.exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            delegate.onDistanceUnitChange(unit)
                            viewModel.distanceUnit = unit
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == viewModel.distanceUnit {
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
    
    @ViewBuilder
    private var setsContent: some View {
        // Rows (each row is its own view to keep swipe actions per-row)
        Group {
            ZStack(alignment: .topLeading) {
                if viewModel.notesDraft.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                }
                TextEditor(text: $viewModel.notesDraft)
                    .scrollContentBackground(.hidden)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: viewModel.notesDraft) { _, newValue in
                        delegate.onNotesChange(newValue)
                    }
            }

            ForEach(delegate.exercise.sets) { set in
                setTrackerRowView(
                    SetTrackerRowViewDelegate(
                        set: set,
                        trackingMode: viewModel.exercise.trackingMode,
                        weightUnit: viewModel.weightUnit,
                        distanceUnit: viewModel.distanceUnit,
                        previousSet: viewModel.previousSetsByIndex[set.index],
                        restBeforeSec: delegate.restBeforeSecForSet(set.id),
                        onRestBeforeChange: { delegate.onRestBeforeChange(set.id, $0) },
                        onRequestRestPicker: { _, _ in delegate.onRequestRestPicker(set.id, delegate.restBeforeSecForSet(set.id)) },
                        onUpdate: delegate.onSetUpdate
                    )
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delegate.onDeleteSet(set.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .moveDisabled(true)
            }
            .listRowSeparator(.hidden)

            // Add set button
            Button {
                delegate.onAddSet()
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

        }
        .listRowInsets(.vertical, .zero)
        .listRowInsets(.leading, .zero)
    }
}

private struct ExerciseTrackerCardPreviewContainer: View {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    @State private var exercise: WorkoutExerciseModel = {
        var exercise = WorkoutExerciseModel.mock
        exercise.notes = exercise.notes ?? ""
        // Ensure at least a couple sets exist for interactions
        if exercise.sets.isEmpty {
            exercise.sets = [
                WorkoutSetModel(
                    id: UUID().uuidString,
                    authorId: "preview",
                    index: 1,
                    reps: 8,
                    weightKg: 40,
                    durationSec: nil,
                    distanceMeters: nil,
                    rpe: 7,
                    isWarmup: false,
                    completedAt: nil,
                    dateCreated: Date()
                ),
                WorkoutSetModel(
                    id: UUID().uuidString,
                    authorId: "preview",
                    index: 2,
                    reps: 8,
                    weightKg: 40,
                    durationSec: nil,
                    distanceMeters: nil,
                    rpe: 7,
                    isWarmup: false,
                    completedAt: nil,
                    dateCreated: Date()
                )
            ]
        }
        return exercise
    }()

    @State private var isExpandedCurrent = true
    @State private var isExpandedOther = false

    var body: some View {
        RouterView { router in
            List {
                // Current exercise styled card
                builder.exerciseTrackerCardView(
                    router: router,
                    delegate: ExerciseTrackerCardViewDelegate(
                        exercise: exercise,
                        exerciseIndex: 0,
                        isCurrentExercise: true,
                        weightUnit: .kilograms,
                        distanceUnit: .meters,
                        previousSetsByIndex: [:],
                        onSetUpdate: handleUpdate,
                        onAddSet: handleAdd,
                        onDeleteSet: handleDelete,
                        onHeaderLongPress: {},
                        onNotesChange: { exercise.notes = $0 },
                        onWeightUnitChange: { _ in },
                        onDistanceUnitChange: { _ in },
                        restBeforeSecForSet: { _ in nil },
                        onRestBeforeChange: { _, _ in },
                        onRequestRestPicker: { _, _ in },
                        getLatestExercise: { exercise },
                        getLatestExerciseIndex: { 0 },
                        getLatestIsCurrentExercise: { true },
                        getLatestWeightUnit: { .kilograms },
                        getLatestDistanceUnit: { .meters },
                        getLatestPreviousSets: { [:] },
                        isExpanded: $isExpandedCurrent
                    )
                )
                // Non-current exercise styled card
                builder.exerciseTrackerCardView(
                    router: router,
                    delegate: ExerciseTrackerCardViewDelegate(
                        exercise: exercise,
                        exerciseIndex: 1,
                        isCurrentExercise: false,
                        weightUnit: .kilograms,
                        distanceUnit: .meters,
                        previousSetsByIndex: [:],
                        onSetUpdate: handleUpdate,
                        onAddSet: handleAdd,
                        onDeleteSet: handleDelete,
                        onHeaderLongPress: {},
                        onNotesChange: { exercise.notes = $0 },
                        onWeightUnitChange: { _ in },
                        onDistanceUnitChange: { _ in },
                        restBeforeSecForSet: { _ in nil },
                        onRestBeforeChange: { _, _ in },
                        onRequestRestPicker: { _, _ in },
                        getLatestExercise: { exercise },
                        getLatestExerciseIndex: { 1 },
                        getLatestIsCurrentExercise: { false },
                        getLatestWeightUnit: { .kilograms },
                        getLatestDistanceUnit: { .meters },
                        getLatestPreviousSets: { [:] },
                        isExpanded: $isExpandedOther
                    )
                )
            }
        }
    }

    private func handleUpdate(_ updatedSet: WorkoutSetModel) {
        if let index = exercise.sets.firstIndex(where: { $0.id == updatedSet.id }) {
            exercise.sets[index] = updatedSet
        }
    }

    private func handleAdd() {
        let nextIndex = exercise.sets.count + 1
        let last = exercise.sets.last
        let new = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: "preview",
            index: nextIndex,
            reps: last?.reps ?? 8,
            weightKg: last?.weightKg ?? 40,
            durationSec: last?.durationSec,
            distanceMeters: last?.distanceMeters,
            rpe: last?.rpe ?? 7,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        )
        exercise.sets.append(new)
    }

    private func handleDelete(_ id: String) {
        exercise.sets.removeAll { $0.id == id }
        reindex()
    }

    private func completeFirst() {
        guard !exercise.sets.isEmpty else { return }
        exercise.sets[0].completedAt = Date()
    }

    private func reset() {
        for index in exercise.sets.indices {
            exercise.sets[index].completedAt = nil
        }
        isExpandedCurrent = true
        isExpandedOther = false
        reindex()
    }

    private func reindex() {
        for index in exercise.sets.indices {
            exercise.sets[index].index = index + 1
        }
    }
}

#Preview {
    ExerciseTrackerCardPreviewContainer()
        .previewEnvironment()
}
