//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import HealthKit
import SwiftfulRouting
import Combine

struct WorkoutTrackerDelegate {
    let workoutSessionId: String
}

struct WorkoutTrackerView: View {

    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutTrackerPresenter
    let delegate: WorkoutTrackerDelegate

    @ViewBuilder var exerciseTrackerCardView: (ExerciseTrackerCardDelegate) -> AnyView

    var body: some View {
        List {
            workoutOverviewCard
                .listSectionMargins(.top, 0)
            exerciseSection
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $presenter.editMode)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            timerHeaderView()
        }
        .task(id: delegate.workoutSessionId) {
            await presenter.loadWorkoutSession(delegate.workoutSessionId)
            await presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("🌗 WorkoutTrackerView.scenePhase changed \(oldPhase) -> \(newPhase) for session id=\(delegate.workoutSessionId)")
            presenter.onScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
        }
    }

    // MARK: - UI Components
    // MARK: - Workout Overview Card
    
    private var workoutOverviewCard: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Workout")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(presenter.exercisesCount)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Sets Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(presenter.completedSetsFraction)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                
                // Quick stats
                HStack(spacing: 20) {
                    StatCard(
                        value: presenter.exerciseFraction,
                        label: "Exercise",
                    )
                    StatCard(
                        value: presenter.formattedVolume,
                        label: "Volume"
                    )
                    StatCard(
                        value: presenter.workoutNotes.isEmpty ? "None" : "View",
                        label: "Notes"
                    )
                    .onTapGesture {
                        presenter.presentWorkoutNotes()
                    }
                }
            }
        } header: {
            Text("Workout Overview")
        }
    }

    // MARK: - Exercise Section Card

    private var exerciseSection: some View {
        // Exercise List
        Section {
            if presenter.workoutSession.exercises.isEmpty {
                ContentUnavailableView {
                    Text("No Exercises")
                } description: {
                    Text("Please add some exercises to get started.")
                }
                .removeListRowFormatting()
            } else {
                ForEach(Array(presenter.workoutSession.exercises.enumerated()), id: \.element.id) { index, exercise in
                    let isExpanded = Binding<Bool>(
                        get: {
                            presenter.expandedExerciseIds.contains(exercise.id)
                        },
                        set: { newValue in
                            if newValue {
                                presenter.expandedExerciseIds = []
                                presenter.expandedExerciseIds.insert(exercise.id)
                            } else {
                                presenter.expandedExerciseIds.remove(exercise.id)
                            }
                        }
                    )
                    
                    let delegate = ExerciseTrackerCardDelegate(
                        exercise: exercise,
                        exerciseIndex: index,
                        isCurrentExercise: presenter.currentExerciseIndex == index,
                        isExpanded: isExpanded,
                        restBeforeSetIdToSec: presenter.restBeforeSetIdToSec,
                        onNotesChanged: { notes, exerciseId in
                            presenter.updateExerciseNotes(notes, exerciseId: exerciseId)
                        },
                        onAddSet: { exerciseId in
                            presenter.addSet(exerciseId: exerciseId)
                        },
                        onDeleteSet: { setId, exerciseId in
                            presenter.deleteSet(setId: setId, exerciseId: exerciseId)
                        },
                        onUpdateSet: { updatedSet, exerciseId in
                            presenter.updateSet(updatedSet, in: exerciseId)
                        },
                        onRestBeforeChange: { setId, seconds in
                            presenter.updateRestBefore(setId: setId, seconds: seconds)
                        }
                    )
                    
                    exerciseTrackerCardView(delegate)
                }
                .onMove { source, destination in
                    presenter.moveExercises(from: source, to: destination)
                }
            }
            
        } header: {
            Text("Exercises")
        }
    }
    
    // MARK: - Timer Header
    @ViewBuilder
    private func timerHeaderView() -> some View {
        if presenter.isRestActive {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(presenter.isRestActive ? "Rest Timer" : "Workout Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    if let end = presenter.restEndTime {
                        let now = Date()
                        if now < end {
                            Text(timerInterval: now...end)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        } else {
                            Text("00:00")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                    } else {
                        Text((presenter.workoutSession.dateCreated), style: .timer)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    #endif
                }
                
                Spacer()
            }
            .padding()
            .background(.bar)
        }
    }
    
    private var deleteWorkoutSection: some View {
        Button {
            presenter.onDiscardWorkoutPressed()
        } label: {
            Text("Delete Workout")
                .foregroundStyle(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.2))
        }
        .removeListRowFormatting()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .title) {
            TextField(text: $presenter.workoutSession.name) {
                Text(presenter.workoutSession.name)
            }
        }
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {

                } label: {
                    Label("Resume Workout", systemImage: "play")
                }
                Button {
                    presenter.minimizeSession()
                } label: {
                    Label("Minimise Tracker", systemImage: "xmark")
                }

                Button {
                    presenter.finishWorkout()
                } label: {
                    Label("Finish Workout", systemImage: "checkmark")
                }

                Button {

                } label: {
                    Label("Workout Settings", systemImage: "gear")
                }

                Button {

                } label: {
                    Label("Gym Settings", systemImage: "gear")
                }

                Button(role: .destructive) {
                    presenter.onDiscardWorkoutPressed()
                } label: {
                    Label("Delete Workout", systemImage: "trash")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
    }
}

extension CoreBuilder {
    func workoutTrackerView(router: AnyRouter, delegate: WorkoutTrackerDelegate) -> some View {
        WorkoutTrackerView(
            presenter: WorkoutTrackerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            exerciseTrackerCardView: { delegate in
                self.exerciseTrackerCardView(router: router, delegate: delegate)
                    .any()
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.workoutTrackerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutTrackerView(router: router, delegate: WorkoutTrackerDelegate(workoutSessionId: WorkoutSessionModel.mock.id))
    }
    .previewEnvironment()
}
