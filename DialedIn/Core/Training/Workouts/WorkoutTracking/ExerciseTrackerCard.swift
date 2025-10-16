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
    let onSetUpdate: (WorkoutSetModel) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    let onHeaderLongPress: () -> Void
    
    @Binding var isExpanded: Bool
    
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
        }
        .tappableBackground()
        .onLongPressGesture(minimumDuration: 0.4) {
            onHeaderLongPress()
        }
    }
    
    private var setsContent: some View {
        Group {
            ForEach(exercise.sets) { set in
                SetTrackerRow(
                    set: set,
                    trackingMode: exercise.trackingMode,
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
            
            // Add set button
            Button {
                onAddSet()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .font(.footnote.bold())
                .foregroundColor(.blue)
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Computed Properties
    
    private var completedSetsCount: Int {
        exercise.sets.filter { $0.completedAt != nil }.count
    }
    
}

private struct ExerciseTrackerCardPreviewContainer: View {
    @State private var exercise: WorkoutExerciseModel = {
        var exercise = WorkoutExerciseModel.mock
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
