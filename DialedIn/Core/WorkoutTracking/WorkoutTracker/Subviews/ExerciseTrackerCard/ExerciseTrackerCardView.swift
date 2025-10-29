//
//  ExerciseTrackerCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct ExerciseTrackerCardView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ExerciseTrackerCardViewModel

    @Binding var isExpanded: Bool
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            setsContent
        } label: {
            exerciseHeader
        }
        .onChange(of: isExpanded) { _, newValue in
            if newValue {
                // Refresh exercise data when card expands
                viewModel.refreshExercise()
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
            viewModel.onHeaderLongPress()
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
                            viewModel.onWeightUnitChange(unit)
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
                            viewModel.onDistanceUnitChange(unit)
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
                        viewModel.onNotesChange(newValue)
                    }
            }

            ForEach(viewModel.exercise.sets) { set in
                SetTrackerRowView(
                    viewModel: SetTrackerRowViewModel(
                        container: container,
                        set: set,
                        trackingMode: viewModel.exercise.trackingMode,
                        weightUnit: viewModel.weightUnit,
                        distanceUnit: viewModel.distanceUnit,
                        previousSet: viewModel.previousSetsByIndex[set.index],
                        restBeforeSec: viewModel.restBeforeSecForSet(set.id),
                        onRestBeforeChange: { viewModel.onRestBeforeChange(set.id, $0) },
                        onRequestRestPicker: { _, _ in viewModel.onRequestRestPicker(set.id, viewModel.restBeforeSecForSet(set.id)) },
                        onUpdate: viewModel.onSetUpdate
                    )
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.onDeleteSet(set.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .moveDisabled(true)
            }
            .listRowSeparator(.hidden)

            // Add set button
            Button {
                viewModel.onAddSet()
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
            ExerciseTrackerCardView(
                viewModel: ExerciseTrackerCardViewModel(
                    interactor: CoreInteractor(
                        container: DevPreview.shared.container
                    ),
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
                    getLatestExercise: { exercise }
                ),
                isExpanded: $isExpandedCurrent
            )
            
            // Non-current exercise styled card
            ExerciseTrackerCardView(
                viewModel: ExerciseTrackerCardViewModel(
                    interactor: CoreInteractor(
                        container: DevPreview.shared.container
                    ),
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
                    getLatestExercise: { exercise }
                ),
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
