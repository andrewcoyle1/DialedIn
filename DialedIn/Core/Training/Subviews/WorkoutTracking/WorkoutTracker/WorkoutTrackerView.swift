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

    @ViewBuilder var exerciseTrackerView: (ExerciseTrackerDelegate) -> ExerciseTracker
    
    var body: some View {
        List {
            workoutOverviewCard
            exerciseSection
        }
        .navigationTitle(presenter.workoutSession.name)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.browser)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $presenter.editMode)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            if presenter.isRestActive {
                timerHeaderView
            }
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
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 16) {
                VStack(alignment: .center, spacing: 4) {
                    Text("Current Workout")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(presenter.exercisesCount)
                        .font(.headline)
                }
                VStack(alignment: .center, spacing: 4) {
                    Text("Sets Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(presenter.completedSetsFraction)
                        .font(.headline)
                        .foregroundColor(.green)
                }
                VStack(alignment: .center, spacing: 4) {
                    Text("Elapsed Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(presenter.workoutSession.dateCreated, style: .timer)
                        .font(.headline)
                }
                StatCard(
                    value: presenter.exerciseFraction,
                    label: "Exercise",
                    alignment: .center
                )
                StatCard(
                    value: presenter.formattedVolume,
                    label: "Volume",
                    alignment: .center
                )
                StatCard(
                    value: presenter.workoutNotes.isEmpty ? "None" : "View",
                    label: "Notes",
                    alignment: .center
                )
                .onTapGesture {
                    presenter.presentWorkoutNotes()
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
                    let exerciseId = exercise.id
                    let isExpanded = Binding<Bool>(
                        get: { presenter.expandedExerciseId == exerciseId },
                        set: { presenter.expandedExerciseId = $0 ? exerciseId : nil }
                    )
                    let delegate = ExerciseTrackerDelegate(
                        exercise: $exercise,
                        lastExercise: presenter.previousWorkoutSession?.exercises.first(
                            where: { previousExercise in
                                previousExercise.templateId == exercise.templateId
                            }
                        ),
                        isExpanded: isExpanded
                    )
                    exerciseTrackerView(delegate)
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
        HStack {
            let now = Date()
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
        .padding(8)
        .padding(.horizontal, 8)
        .glassEffect()
        .padding()
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
    func workoutTrackerView(router: AnyRouter) throws -> some View {
        let trackerPresenter = try WorkoutTrackerPresenter(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self)
        )
        return WorkoutTrackerView(
            presenter: trackerPresenter,
            exerciseTrackerView: { delegate in
                self.exerciseTrackerView(
                    router: router,
                    delegate: delegate,
                    onStartRest: { [weak trackerPresenter] duration in
                        trackerPresenter?.startRestTimer(durationSeconds: duration)
                    }
                )
            }
        )
    }
}

extension CoreRouter {
    func showWorkoutTrackerView() {
        router.showScreen(.fullScreenCover) { router in
            try? builder.workoutTrackerView(router: router)
        }
    }
}

#Preview("With Exercises") {
    let container = DevPreview.shared.container()
    let activeWorkoutSessionPersistence = MockLocalDocumentPersistence<WorkoutSessionModel>(document: WorkoutSessionModel.mock)
    let userWorkoutSessionSyncEngine = CollectionSyncEngine<WorkoutSessionModel>(
        remote: MockRemoteCollectionService(),
        managerKey: Keys.userWorkoutSessionManagerKey
    )
    let followingWorkoutSessionSyncEngine = CollectionGroupSyncEngine<WorkoutSessionModel>(
        remote: MockRemoteCollectionGroupService(),
        managerKey: Keys.followingWorkoutSessionsManagerKey
    )
    let workoutSessionManager = WorkoutSessionManager(
        activeWorkoutSessionPersistence: activeWorkoutSessionPersistence,
        userWorkoutSessionSyncEngine: userWorkoutSessionSyncEngine,
        followingWorkoutSessionSyncEngine: followingWorkoutSessionSyncEngine
    )
    container.register(WorkoutSessionManager.self, service: workoutSessionManager)
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    return RouterView { router in
        try? builder.workoutTrackerView(router: router)
    }
    
}

#Preview ("No Exercises"){
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        try? builder.workoutTrackerView(router: router)
    }
    
}
