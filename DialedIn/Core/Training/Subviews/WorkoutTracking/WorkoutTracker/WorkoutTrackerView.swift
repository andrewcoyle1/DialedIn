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

// MARK: - Host view (creates presenter once per presentation to avoid fullScreenCover re-run loop)
struct WorkoutTrackerHostView: View {
    let delegate: WorkoutTrackerDelegate
    let interactor: WorkoutTrackerInteractor
    let router: WorkoutTrackerRouter
    @State private var presenter: WorkoutTrackerPresenter?

    var body: some View {
        Group {
            if let presenter {
                WorkoutTrackerView(presenter: presenter, delegate: delegate)
            } else {
                ProgressView("Loading workout...")
            }
        }
        .task(id: delegate.workoutSessionId) {
            if presenter == nil {
                presenter = WorkoutTrackerPresenter(interactor: interactor, router: router)
            }
        }
    }
}

struct WorkoutTrackerView: View {

    @Environment(\.scenePhase) private var scenePhase
    
    @State var presenter: WorkoutTrackerPresenter
    let delegate: WorkoutTrackerDelegate

    var body: some View {
        List {
            workoutOverviewCard
                .listSectionMargins(.top, 0)
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
                ForEach(Array(presenter.workoutSession.exercises.enumerated()), id: \.element.id) { _, exercise in
                    exerciseTracker(exercise)
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
    func workoutTrackerView(router: AnyRouter, delegate: WorkoutTrackerDelegate) -> some View {
        WorkoutTrackerHostView(
            delegate: delegate,
            interactor: interactor,
            router: CoreRouter(router: router, builder: self)
        )
        .id(delegate.workoutSessionId)
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.workoutTrackerView(router: router, delegate: WorkoutTrackerDelegate(workoutSessionId: WorkoutSessionModel.mock.id))
    }
    
}
