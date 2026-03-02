//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import HealthKit
import Combine

struct WorkoutTrackerView<ExerciseTracker: View>: View {

    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutTrackerPresenter

    @ViewBuilder var exerciseTrackerView: (Binding<WorkoutExerciseModel>) -> ExerciseTracker
    
    var body: some View {
        List {
            workoutOverviewCard
            exerciseSection
        }
        .navigationTitle(presenter.workoutSession.name)
        .toolbarTitleDisplayMode(.inlineLarge)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $presenter.editMode)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            timerHeaderView
        }
        .task {
            await presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
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
        .listSectionMargins(.top, 0)
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
                ForEach($presenter.workoutSession.exercises) { $exercise in
                    exerciseTrackerView($exercise)
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
    private var timerHeaderView: some View {
        Group {
            if presenter.isRestActive {
                let now = Date()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rest Timer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let end = presenter.restEndTime,
                           now < end {
                            Text(timerInterval: now...end)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        } else {
                            Text((presenter.workoutSession.dateCreated), style: .timer)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                }
            } else if presenter.showWorkoutTimer {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workout Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(presenter.workoutSession.dateCreated, style: .timer)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .glassEffect()
        .padding(.horizontal)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
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
                    presenter.onWorkoutSettingsPressed()
                } label: {
                    Label("Workout Settings", systemImage: "dumbbell")
                }

                Button {
                    presenter.onGymProfilePressed()
                } label: {
                    Label("Gym Settings", systemImage: "building")
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
    func workoutTrackerView(router: AnyRouter) -> some View {
        let trackerPresenter = WorkoutTrackerPresenter(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self)
        )
        return WorkoutTrackerView(
            presenter: trackerPresenter,
            exerciseTrackerView: { exercise in
                self.exerciseTrackerView(
                    router: router,
                    delegate: ExerciseTrackerDelegate(exercise: exercise)
                )
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutTrackerView() {
        router.showScreen(.fullScreenCover) { router in
            builder.workoutTrackerView(router: router)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.workoutTrackerView(router: router)
    }
    
}
