//
//  ExerciseTrackerCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct ExerciseTrackerCard: View {
    let exercise: WorkoutExerciseModel
    let exerciseIndex: Int
    let isCurrentExercise: Bool
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let previousSetsByIndex: [Int: WorkoutSetModel]
    let onSetUpdate: (WorkoutSetModel) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    let onHeaderLongPress: () -> Void
    let onNotesChange: (String) -> Void
    let onWeightUnitChange: (ExerciseWeightUnit) -> Void
    let onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
    // Rest configuration for the next set (child set) keyed by set id
    let restBeforeSecForSet: (String) -> Int?
    let onRestBeforeChange: (String, Int?) -> Void
    let onRequestRestPicker: (String, Int?) -> Void
    
    @Binding var isExpanded: Bool
    @State private var notesDraft: String = ""

    init(
        exercise: WorkoutExerciseModel,
        exerciseIndex: Int,
        isCurrentExercise: Bool,
        weightUnit: ExerciseWeightUnit = .kilograms,
        distanceUnit: ExerciseDistanceUnit = .meters,
        previousSetsByIndex: [Int: WorkoutSetModel] = [:],
        onSetUpdate: @escaping (WorkoutSetModel) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onHeaderLongPress: @escaping () -> Void,
        onNotesChange: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void = { _ in },
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void = { _ in },
        restBeforeSecForSet: @escaping (String) -> Int?,
        onRestBeforeChange: @escaping (String, Int?) -> Void,
        onRequestRestPicker: @escaping (String, Int?) -> Void,
        isExpanded: Binding<Bool>
    ) {
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.isCurrentExercise = isCurrentExercise
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSetsByIndex = previousSetsByIndex
        self.onSetUpdate = onSetUpdate
        self.onAddSet = onAddSet
        self.onDeleteSet = onDeleteSet
        self.onHeaderLongPress = onHeaderLongPress
        self.onNotesChange = onNotesChange
        self.onWeightUnitChange = onWeightUnitChange
        self.onDistanceUnitChange = onDistanceUnitChange
        self.restBeforeSecForSet = restBeforeSecForSet
        self.onRestBeforeChange = onRestBeforeChange
        self.onRequestRestPicker = onRequestRestPicker
        self._isExpanded = isExpanded
        // Initialize local draft from model notes if available
        self._notesDraft = State(initialValue: exercise.notes ?? "")
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            setsContent
        } label: {
            exerciseHeader
        }
    }
    
    private var exerciseHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(exerciseIndex + 1).")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Text("\(completedSetsCount)/\(exercise.sets.count) sets")
                .font(.caption)
                .foregroundColor(completedSetsCount == exercise.sets.count ? .green : .secondary)
            
            Spacer()
            
            // Unit preference menu
            unitPreferenceMenu
        }
        .tappableBackground()
        .onLongPressGesture(minimumDuration: 0.4) {
            onHeaderLongPress()
        }
        .listRowInsets(.vertical, .zero)
    }
    
    @ViewBuilder
    private var unitPreferenceMenu: some View {
        Menu {
            // Show weight options for exercises that track weight
            if exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
                            onWeightUnitChange(unit)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == weightUnit {
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
            if exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            onDistanceUnitChange(unit)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == distanceUnit {
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
                if notesDraft.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                }
                TextEditor(text: $notesDraft)
                    .scrollContentBackground(.hidden)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: notesDraft) { _, newValue in
                        onNotesChange(newValue)
                    }
            }

            ForEach(exercise.sets) { set in
                SetTrackerRow(
                    set: set,
                    trackingMode: exercise.trackingMode,
                    weightUnit: weightUnit,
                    distanceUnit: distanceUnit,
                    previousSet: previousSetsByIndex[set.index],
                    restBeforeSec: restBeforeSecForSet(set.id),
                    onRestBeforeChange: { onRestBeforeChange(set.id, $0) },
                    onRequestRestPicker: { _, _ in onRequestRestPicker(set.id, restBeforeSecForSet(set.id)) },
                    onUpdate: onSetUpdate
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDeleteSet(set.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .moveDisabled(true)
            }
            .listRowSeparator(.hidden)

            // Add set button
            Button {
                onAddSet()
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
    
    // MARK: - Computed Properties
    private var completedSetsCount: Int {
        exercise.sets.filter { $0.completedAt != nil }.count
    }
}

private struct ExerciseTrackerCardPreviewContainer: View {
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
        List {
            // Current exercise styled card
            ExerciseTrackerCard(
                exercise: exercise,
                exerciseIndex: 0,
                isCurrentExercise: true,
                onSetUpdate: handleUpdate,
                onAddSet: handleAdd,
                onDeleteSet: handleDelete,
                onHeaderLongPress: {},
                onNotesChange: { exercise.notes = $0 },
                restBeforeSecForSet: { _ in nil },
                onRestBeforeChange: { _, _ in },
                onRequestRestPicker: { _, _ in },
                isExpanded: $isExpandedCurrent
            )

            // Non-current exercise styled card
            ExerciseTrackerCard(
                exercise: exercise,
                exerciseIndex: 1,
                isCurrentExercise: false,
                onSetUpdate: handleUpdate,
                onAddSet: handleAdd,
                onDeleteSet: handleDelete,
                onHeaderLongPress: {},
                onNotesChange: { exercise.notes = $0 },
                restBeforeSecForSet: { _ in nil },
                onRestBeforeChange: { _, _ in },
                onRequestRestPicker: { _, _ in },
                isExpanded: $isExpandedOther
            )
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
