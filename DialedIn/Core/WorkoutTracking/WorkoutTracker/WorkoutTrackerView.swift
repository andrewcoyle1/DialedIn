//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import HealthKit
import CustomRouting

struct WorkoutTrackerViewDelegate {
    let workoutSession: WorkoutSessionModel
}

struct WorkoutTrackerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    // ViewModel
    @State var viewModel: WorkoutTrackerViewModel
    
    let delegate: WorkoutTrackerViewDelegate

    @ViewBuilder var exerciseTrackerCardView: (ExerciseTrackerCardViewDelegate) -> AnyView

    var body: some View {
        TimelineView(.periodic(from: delegate.workoutSession.dateCreated, by: 1.0)) { _ in
            NavigationStack {
                List {
                    workoutOverviewCard
                    exerciseSection
                }
                .navigationTitle(viewModel.workoutSession?.name ?? delegate.workoutSession.name)
                .navigationSubtitle(viewModel.elapsedTimeString)
                .navigationBarTitleDisplayMode(.large)
                .scrollIndicators(.hidden)
                .environment(\.editMode, $viewModel.editMode)
                .toolbar {
                    toolbarContent
                }
                .safeAreaInset(edge: .bottom) {
                    timerHeaderView()
                }
                .showCustomAlert(alert: $viewModel.showAlert)
            }
            .task {
                viewModel.loadWorkoutSession(delegate.workoutSession)
                await viewModel.onAppear()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                viewModel.onScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
            }
            .showModal(showModal: $viewModel.isRestPickerOpen) {
                setRestModal
            }
            .sheet(isPresented: $viewModel.showingWorkoutNotes) {
                WorkoutNotesView(notes: $viewModel.workoutNotes) {
                    viewModel.updateWorkoutNotes()
                }
            }
        }
    }

    // MARK: - UI Components
    // MARK: - Workout Overview Card
    
    private var workoutOverviewCard: some View {
        Section {
            if let workoutSession = viewModel.workoutSession {
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
                            
                            Text("\(viewModel.completedSetsCount)/\(viewModel.totalSetsCount)")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Quick stats
                    HStack(spacing: 20) {
                        StatCard(
                            value: "\(viewModel.currentExerciseIndex + 1)/\(workoutSession.exercises.count)",
                            label: "Exercise",
                        )
                        StatCard(
                            value: viewModel.formattedVolume,
                            label: "Volume"
                        )
                        if !viewModel.workoutNotes.isEmpty {
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
            if let workoutSession = viewModel.workoutSession {
                ForEach(workoutSession.exercises, id: \.id) { exercise in
                    let index = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                    let preference = viewModel.exerciseUnitPreferences[exercise.templateId]
                    let weightUnit = preference?.weightUnit ?? .kilograms
                    let distanceUnit = preference?.distanceUnit ?? .meters
                    let previousSets = viewModel.buildPreviousLookup(for: exercise)
                    let exerciseId = exercise.id
                    exerciseTrackerCardView(
                        ExerciseTrackerCardViewDelegate(
                            exercise: exercise,
                            exerciseIndex: index,
                            isCurrentExercise: index == viewModel.currentExerciseIndex,
                            weightUnit: weightUnit,
                            distanceUnit: distanceUnit,
                            previousSetsByIndex: previousSets,
                            onSetUpdate: { updatedSet in viewModel.updateSet(updatedSet, in: exerciseId) },
                            onAddSet: { viewModel.addSet(to: exerciseId) },
                            onDeleteSet: { setId in viewModel.deleteSet(setId, from: exerciseId) },
                            onHeaderLongPress: { /* no-op: reordering via drag on header */ },
                            onNotesChange: { notes in viewModel.updateExerciseNotes(notes, for: exerciseId) },
                            onWeightUnitChange: { unit in viewModel.updateWeightUnit(unit, for: exercise.templateId) },
                            onDistanceUnitChange: { unit in viewModel.updateDistanceUnit(unit, for: exercise.templateId) },
                            restBeforeSecForSet: { setId in viewModel.getRestBeforeSet(setId: setId) },
                            onRestBeforeChange: { setId, value in viewModel.updateRestBeforeSet(setId: setId, value: value) },
                            onRequestRestPicker: { setId, current in
                                viewModel.openRestPicker(for: setId, currentValue: current)
                                viewModel.isRestPickerOpen = true
                            },
                            getLatestExercise: {
                                viewModel.workoutSession?.exercises.first(where: { $0.id == exerciseId })
                            },
                            getLatestExerciseIndex: {
                                viewModel.workoutSession?.exercises.firstIndex(where: { $0.id == exerciseId }) ?? 0
                            },
                            getLatestIsCurrentExercise: {
                                guard let workoutSession = viewModel.workoutSession else { return false }
                                let currentIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) ?? 0
                                return currentIndex == viewModel.currentExerciseIndex
                            },
                            getLatestWeightUnit: {
                                guard let workoutSession = viewModel.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return .kilograms
                                }
                                let preference = viewModel.exerciseUnitPreferences[latestExercise.templateId]
                                return preference?.weightUnit ?? .kilograms
                            },
                            getLatestDistanceUnit: {
                                guard let workoutSession = viewModel.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return .meters
                                }
                                let preference = viewModel.exerciseUnitPreferences[latestExercise.templateId]
                                return preference?.distanceUnit ?? .meters
                            },
                            getLatestPreviousSets: {
                                guard let workoutSession = viewModel.workoutSession,
                                      let latestExercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
                                    return [:]
                                }
                                return viewModel.buildPreviousLookup(for: latestExercise)
                            },
                            isExpanded: Binding(
                                get: { viewModel.expandedExerciseIds.contains(exercise.id) },
                                set: { newValue in
                                    if newValue {
                                        // Allow only one expanded at a time: collapse current first
                                        viewModel.expandedExerciseIds.removeAll()
                                        viewModel.expandedExerciseIds.insert(exercise.id)
                                    } else {
                                        viewModel.expandedExerciseIds.remove(exercise.id)
                                    }
                                }
                            )
                        )
                    )
                }
                .onMove { source, destination in
                    viewModel.moveExercises(from: source, to: destination)
                }
            }
        } header: {
            Text("Exercises")
        }
    }
    
    // MARK: - Timer Header
    @ViewBuilder
    private func timerHeaderView() -> some View {
        if viewModel.isRestActive {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isRestActive ? "Rest Timer" : "Workout Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    if let end = viewModel.restEndTime {
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
                        Text((viewModel.workoutSession?.dateCreated ?? delegate.workoutSession.dateCreated), style: .timer)
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
                viewModel.minimizeSession(onDismiss: { dismiss() })
            } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .destructive) {
                viewModel.showAlert = AnyAppAlert(
                    title: "End Workout?",
                    subtitle: "Are you sure you want to discard this workout?"
                ) {
                    AnyView(
                        VStack {
                            Button("Cancel", role: .cancel) {
                                viewModel.showAlert = nil
                            }
                            Button("Discard", role: .destructive) {
                                viewModel.discardWorkout(onDismiss: { dismiss() })
                            }
                        }
                    )
                }
            } label: {
                Image(systemName: "trash")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.presentWorkoutNotes()
            } label: {
                Image(systemName: "long.text.page.and.pencil")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.finishWorkout(onDismiss: { dismiss() })
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                if viewModel.isRestActive {
                    viewModel.cancelRestTimer()
                } else {
                    viewModel.startRestTimer()
                }
            } label: {
                Image(systemName: viewModel.isRestActive ? "stop" : "timer")
                    .foregroundColor(viewModel.isRestActive ? .red : .accent)
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.pendingSelectedTemplates = []
                viewModel.presentAddExercise()
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
                viewModel.saveRestPickerValue()
                viewModel.isRestPickerOpen = false
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: { viewModel.isRestPickerOpen = false },
            middleContent: AnyView(
                HStack(spacing: 16) {
                    Picker("Minutes", selection: Binding(
                        get: { viewModel.restPickerMinutesSelection },
                        set: { viewModel.restPickerMinutesSelection = $0 }
                    )) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute) m").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Picker("Seconds", selection: Binding(
                        get: { viewModel.restPickerSecondsSelection },
                        set: { viewModel.restPickerSecondsSelection = $0 }
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

struct WorkoutNotesView: View {
    @Binding var notes: String
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Workout Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Tracker View") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutTrackerView(router: router, delegate: WorkoutTrackerViewDelegate(workoutSession: .mock))
    }
    .previewEnvironment()
}
