//
//  ExerciseTrackerCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ExerciseTrackerCardView: View {

    @State var presenter: ExerciseTrackerCardPresenter
    
    var delegate: ExerciseTrackerCardDelegate

    @ViewBuilder var setTrackerRowView: (SetTrackerRowDelegate) -> AnyView

    var body: some View {
        @Bindable var presenter = presenter
        DisclosureGroup(isExpanded: delegate.isExpanded) {
            setsContent
        } label: {
            exerciseHeader
        }
        .onAppear {
            presenter.loadExerciseNotes(delegate.exercise)
        }
    }
    
    private var exerciseHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(delegate.exerciseIndex + 1).")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(delegate.exercise.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Text("\(delegate.exercise.completedSetsCount)/\(delegate.exercise.sets.count) sets")
                .font(.caption)
                .foregroundColor(delegate.exercise.completedSetsCount == delegate.exercise.sets.count ? .green : .secondary)
            
            Spacer()
            
            // Unit preference menu
            unitPreferenceMenu
        }
        .tappableBackground()
        .listRowInsets(.vertical, .zero)
    }
    
    @ViewBuilder
    private var unitPreferenceMenu: some View {
        Menu {
            // Show weight options for exercises that track weight
            if delegate.exercise.trackingMode == .weightReps {
                Menu {
                    ForEach(ExerciseWeightUnit.allCases, id: \.self) { unit in
                        Button {
                            presenter.updateWeightUnit(unit, for: delegate.exercise.id)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == presenter.preference?.weightUnit {
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
            if delegate.exercise.trackingMode == .distanceTime {
                Menu {
                    ForEach(ExerciseDistanceUnit.allCases, id: \.self) { unit in
                        Button {
                            presenter.updateDistanceUnit(unit, for: delegate.exercise.id)
                        } label: {
                            HStack {
                                Text(unit.displayName)
                                if unit == presenter.preference?.distanceUnit {
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
                if presenter.notesDraft.isEmpty {
                        Text("Add notes here...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                }
                TextEditor(text: $presenter.notesDraft)
                    .scrollContentBackground(.hidden)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: presenter.notesDraft) { _, newValue in
                        delegate.onNotesChanged(newValue, delegate.exercise.id)
                    }
            }

            ForEach(delegate.exercise.sets) { set in
                setTrackerRowView(
                    presenter.makeSetDelegate(for: set, exercise: delegate.exercise, parentDelegate: delegate)
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delegate.onDeleteSet(set.id, delegate.exercise.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .moveDisabled(true)
            }
            .listRowSeparator(.hidden)

            // Add set button
            Button {
                delegate.onAddSet(delegate.exercise.id)
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
    let builder = CoreBuilder(container: DevPreview.shared.container())
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
    @State private var restBefore: [String: Int] = [:]

    var body: some View {
        RouterView { router in
            List {
                // Current exercise styled card
                builder.exerciseTrackerCardView(
                    router: router,
                    delegate: ExerciseTrackerCardDelegate(
                        exercise: exercise,
                        exerciseIndex: 0,
                        isCurrentExercise: true,
                        isExpanded: $isExpandedCurrent,
                        restBeforeSetIdToSec: restBefore,
                        onNotesChanged: { notes, _ in
                            exercise.notes = notes
                        },
                        onAddSet: { _ in
                            handleAdd()
                        },
                        onDeleteSet: { setId, _ in
                            handleDelete(setId)
                        },
                        onUpdateSet: { updatedSet, _ in
                            handleUpdate(updatedSet)
                        },
                        onRestBeforeChange: { setId, seconds in
                            handleRestChange(setId: setId, seconds: seconds)
                        }
                    )
                )
                // Non-current exercise styled card
                builder.exerciseTrackerCardView(
                    router: router,
                    delegate: ExerciseTrackerCardDelegate(
                        exercise: exercise,
                        exerciseIndex: 1,
                        isCurrentExercise: false,
                        isExpanded: $isExpandedOther,
                        restBeforeSetIdToSec: restBefore,
                        onNotesChanged: { notes, _ in
                            exercise.notes = notes
                        },
                        onAddSet: { _ in
                            handleAdd()
                        },
                        onDeleteSet: { setId, _ in
                            handleDelete(setId)
                        },
                        onUpdateSet: { updatedSet, _ in
                            handleUpdate(updatedSet)
                        },
                        onRestBeforeChange: { setId, seconds in
                            handleRestChange(setId: setId, seconds: seconds)
                        }
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
        restBefore.removeValue(forKey: id)
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

    private func handleRestChange(setId: String, seconds: Int?) {
        if let seconds {
            restBefore[setId] = seconds
        } else {
            restBefore.removeValue(forKey: setId)
        }
    }

    private func reindex() {
        for index in exercise.sets.indices {
            exercise.sets[index].index = index + 1
        }
    }
}

extension CoreBuilder {
    func exerciseTrackerCardView(router: AnyRouter, delegate: ExerciseTrackerCardDelegate) -> some View {
        ExerciseTrackerCardView(
            presenter: ExerciseTrackerCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            setTrackerRowView: { delegate in
                self.setTrackerRowView(router: router, delegate: delegate)
                    .any()
            }
        )
    }
}

#Preview {
    ExerciseTrackerCardPreviewContainer()
        .previewEnvironment()
}
