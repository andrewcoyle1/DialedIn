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

struct WorkoutTrackerView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    // Presenter
    @State var presenter: WorkoutTrackerPresenter
    @State private var hasLoadedSession = false
    @State private var now = Date()
    
    let delegate: WorkoutTrackerDelegate

    @ViewBuilder var exerciseTrackerCardView: (ExerciseTrackerCardDelegate) -> AnyView

    var body: some View {
        List {
            workoutOverviewCard
            exerciseSection
        }
        .navigationTitle(presenter.workoutSession?.name ?? delegate.workoutSession.name)
        .navigationSubtitle(presenter.elapsedTimeString)
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .environment(\.editMode, $presenter.editMode)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            timerHeaderView()
        }
        .task {
            // Ensure we only perform the heavy load/onAppear logic once per view lifecycle
            guard !hasLoadedSession else { return }
            hasLoadedSession = true
            presenter.loadWorkoutSession(delegate.workoutSession)
            await presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            presenter.onScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
        }
        .showModal(showModal: $presenter.isRestPickerOpen) {
            setRestModal
        }
        // Drive periodic updates via a simple timer rather than wrapping the whole view in TimelineView
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
    }

    // MARK: - UI Components
    // MARK: - Workout Overview Card
    
    private var workoutOverviewCard: some View {
        Section {
            if let workoutSession = presenter.workoutSession {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Workout")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(workoutSession.exercises.count) exercises")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Sets Completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(presenter.completedSetsCount)/\(presenter.totalSetsCount)")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Quick stats
                    HStack(spacing: 20) {
                        StatCard(
                            value: "\(presenter.currentExerciseIndex + 1)/\(workoutSession.exercises.count)",
                            label: "Exercise",
                        )
                        StatCard(
                            value: presenter.formattedVolume,
                            label: "Volume"
                        )
                        if !presenter.workoutNotes.isEmpty {
                            StatCard(
                                value: "Added",
                                label: "Notes"
                            )
                        }
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
            if let workoutSession = presenter.workoutSession {
                ForEach(workoutSession.exercises, id: \.id) { exercise in
                    let index = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                    let preference = presenter.exerciseUnitPreferences[exercise.templateId]
                    let weightUnit = preference?.weightUnit ?? .kilograms
                    let distanceUnit = preference?.distanceUnit ?? .meters
                    let previousSets = presenter.buildPreviousLookup(for: exercise)
                    let exerciseId = exercise.id
                    exerciseTrackerCardView(
                        ExerciseTrackerCardDelegate(
                            exercise: exercise,
                            exerciseIndex: index,
                            isCurrentExercise: index == presenter.currentExerciseIndex,
                            weightUnit: weightUnit,
                            distanceUnit: distanceUnit,
                            previousSetsByIndex: previousSets,
                            onSetUpdate: { updatedSet in presenter.updateSet(updatedSet, in: exerciseId) },
                            onAddSet: { presenter.addSet(to: exerciseId) },
                            onDeleteSet: { setId in presenter.deleteSet(setId, from: exerciseId) },
                            onHeaderLongPress: { /* no-op: reordering via drag on header */ },
                            onNotesChange: { notes in presenter.updateExerciseNotes(notes, for: exerciseId) },
                            onWeightUnitChange: { unit in presenter.updateWeightUnit(unit, for: exercise.templateId) },
                            onDistanceUnitChange: { unit in presenter.updateDistanceUnit(unit, for: exercise.templateId) },
                            restBeforeSecForSet: { setId in presenter.getRestBeforeSet(setId: setId) },
                            onRestBeforeChange: { setId, value in presenter.updateRestBeforeSet(setId: setId, value: value) },
                            onRequestRestPicker: { setId, current in
                                presenter.openRestPicker(for: setId, currentValue: current)
                                presenter.isRestPickerOpen = true
                            },
                            getLatestExercise: {
                                presenter.workoutSession?.exercises.first(where: { $0.id == exerciseId })
                            },
                            getLatestExerciseIndex: {
                                presenter.workoutSession?.exercises.firstIndex(where: { $0.id == exerciseId }) ?? 0
                            },
                            getLatestIsCurrentExercise: {
                                guard let workoutSession = presenter.workoutSession else { return false }
                                let currentIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) ?? 0
                                return currentIndex == presenter.currentExerciseIndex
                            },
                            getLatestWeightUnit: {
                                guard let workoutSession = presenter.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return .kilograms
                                }
                                let preference = presenter.exerciseUnitPreferences[latestExercise.templateId]
                                return preference?.weightUnit ?? .kilograms
                            },
                            getLatestDistanceUnit: {
                                guard let workoutSession = presenter.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return .meters
                                }
                                let preference = presenter.exerciseUnitPreferences[latestExercise.templateId]
                                return preference?.distanceUnit ?? .meters
                            },
                            getLatestPreviousSets: {
                                guard let workoutSession = presenter.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return [:]
                                }
                                return presenter.buildPreviousLookup(for: latestExercise)
                            },
                            isExpanded: Binding(
                                get: { presenter.expandedExerciseIds.contains(exercise.id) },
                                set: { newValue in
                                    if newValue {
                                        // Allow only one expanded at a time: collapse current first
                                        presenter.expandedExerciseIds.removeAll()
                                        presenter.expandedExerciseIds.insert(exercise.id)
                                    } else {
                                        presenter.expandedExerciseIds.remove(exercise.id)
                                    }
                                }
                            )
                        )
                    )
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
                        Text((presenter.workoutSession?.dateCreated ?? delegate.workoutSession.dateCreated), style: .timer)
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
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.minimizeSession()
            } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .destructive) {
                presenter.onDiscardWorkoutPressed()
            } label: {
                Image(systemName: "trash")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.presentWorkoutNotes()
            } label: {
                Image(systemName: "long.text.page.and.pencil")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.finishWorkout()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                if presenter.isRestActive {
                    presenter.cancelRestTimer()
                } else {
                    presenter.startRestTimer()
                }
            } label: {
                Image(systemName: presenter.isRestActive ? "stop" : "timer")
                    .foregroundColor(presenter.isRestActive ? .red : .accent)
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.pendingSelectedTemplates = []
                presenter.presentAddExercise()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private var setRestModal: some View {
        CustomModalView(
            title: "Set Rest",
            subtitle: nil,
            primaryButtonTitle: "Save",
            primaryButtonAction: {
                presenter.saveRestPickerValue()
                presenter.isRestPickerOpen = false
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: { presenter.isRestPickerOpen = false },
            middleContent: AnyView(
                HStack(spacing: 16) {
                    Picker("Minutes", selection: Binding(
                        get: { presenter.restPickerMinutesSelection },
                        set: { presenter.restPickerMinutesSelection = $0 }
                    )) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute) m").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Picker("Seconds", selection: Binding(
                        get: { presenter.restPickerSecondsSelection },
                        set: { presenter.restPickerSecondsSelection = $0 }
                    )) {
                        ForEach(0..<60, id: \.self) { second in
                            Text("\(second) s").tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                    .frame(height: 180)
            )
        )
    }
}

protocol WorkoutNotesInteractor {

}

extension CoreInteractor: WorkoutNotesInteractor { }

@MainActor
protocol WorkoutNotesRouter {
    func dismissScreen()
}

extension CoreRouter: WorkoutNotesRouter { }

@Observable
@MainActor
class WorkoutNotesPresenter {
    let interactor: WorkoutNotesInteractor
    let router: WorkoutNotesRouter

    init(
        interactor: WorkoutNotesInteractor,
        router: WorkoutNotesRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

struct WorkoutNotesDelegate {
    var notes: Binding<String>
    let onSave: () -> Void
}

struct WorkoutNotesView: View {

    @State var presenter: WorkoutNotesPresenter
    var delegate: WorkoutNotesDelegate

    var body: some View {
        VStack {
            TextEditor(text: delegate.notes)
                .padding()

            Spacer()
        }
        .navigationTitle("Workout Notes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    presenter.onDismissPressed()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    delegate.onSave()
                    presenter.onDismissPressed()
                }
            }
        }
    }
}

#Preview("Tracker View") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutTrackerView(router: router, delegate: WorkoutTrackerDelegate(workoutSession: .mock))
    }
    .previewEnvironment()
}
