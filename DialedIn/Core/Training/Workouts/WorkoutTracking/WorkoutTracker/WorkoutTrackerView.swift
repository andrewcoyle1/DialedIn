//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI
import HealthKit

struct WorkoutTrackerView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    // ViewModel
    @State var viewModel: WorkoutTrackerViewModel
    
    // UI-only state
    @State private var showingWorkoutNotes = false
    @State private var showingAddExercise = false
    @State private var editMode: EditMode = .inactive
    @State private var pendingSelectedTemplates: [ExerciseTemplateModel] = []
    @State private var isRestPickerOpen: Bool = false
    
    let initialWorkoutSession: WorkoutSessionModel
    
    var body: some View {
        TimelineView(.periodic(from: viewModel.startTime, by: 1.0)) { _ in
            NavigationStack {
                List {
                    // Workout Overview Section
                    workoutOverviewCard
                    
                    // Exercise Section
                    exerciseSection
                }
                .navigationTitle(viewModel.workoutSession.name)
                .navigationBarTitleDisplayMode(.large)
                .navigationSubtitle(viewModel.elapsedTimeString)
                .scrollIndicators(.hidden)
                .environment(\.editMode, $editMode)
                .toolbar {
                    toolbarContent
                }
                .safeAreaInset(edge: .bottom) {
                    // Timer Header
                    timerHeaderView()
                }
                .showCustomAlert(alert: Binding(
                    get: { viewModel.showAlert },
                    set: { viewModel.showAlert = $0 }
                ))
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                viewModel.onScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
            }
            .showModal(showModal: $isRestPickerOpen) {
                CustomModalView(
                    title: "Set Rest",
                    subtitle: nil,
                    primaryButtonTitle: "Save",
                    primaryButtonAction: {
                        viewModel.saveRestPickerValue()
                        isRestPickerOpen = false
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: { isRestPickerOpen = false },
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
            .sheet(isPresented: $showingWorkoutNotes) {
                WorkoutNotesView(notes: Binding(
                    get: { viewModel.workoutNotes },
                    set: { viewModel.workoutNotes = $0 }
                )) {
                    viewModel.updateWorkoutNotes()
                }
            }
            .sheet(isPresented: $showingAddExercise, onDismiss: {
                viewModel.addSelectedExercises(templates: pendingSelectedTemplates)
                pendingSelectedTemplates = []
            }, content: {
                AddExerciseModalView(
                    viewModel: AddExerciseModalViewModel(
                        container: container,
                        selectedExercises: $pendingSelectedTemplates)
                )
            }
            )
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
                        
                        Text("\(viewModel.workoutSession.exercises.count) exercises")
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
                    StatItem(title: "Exercise", value: "\(viewModel.currentExerciseIndex + 1)/\(viewModel.workoutSession.exercises.count)")
                    StatItem(title: "Volume", value: viewModel.formattedVolume)
                    if !viewModel.workoutNotes.isEmpty {
                        StatItem(title: "Notes", value: "Added")
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
            ForEach(viewModel.workoutSession.exercises, id: \.id) { exercise in
                let index = viewModel.workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                let preference = viewModel.exerciseUnitPreferences[exercise.templateId]
                let weightUnit = preference?.weightUnit ?? .kilograms
                let distanceUnit = preference?.distanceUnit ?? .meters
                let previousSets = viewModel.buildPreviousLookup(for: exercise)
                ExerciseTrackerCard(
                    exercise: exercise,
                    exerciseIndex: index,
                    isCurrentExercise: index == viewModel.currentExerciseIndex,
                    weightUnit: weightUnit,
                    distanceUnit: distanceUnit,
                    previousSetsByIndex: previousSets,
                    onSetUpdate: { updatedSet in viewModel.updateSet(updatedSet, in: exercise.id) },
                    onAddSet: { viewModel.addSet(to: exercise.id) },
                    onDeleteSet: { setId in viewModel.deleteSet(setId, from: exercise.id) },
                    onHeaderLongPress: { /* no-op: reordering via drag on header */ },
                    onNotesChange: { notes in viewModel.updateExerciseNotes(notes, for: exercise.id) },
                    onWeightUnitChange: { unit in viewModel.updateWeightUnit(unit, for: exercise.templateId) },
                    onDistanceUnitChange: { unit in viewModel.updateDistanceUnit(unit, for: exercise.templateId) },
                    restBeforeSecForSet: { setId in viewModel.getRestBeforeSet(setId: setId) },
                    onRestBeforeChange: { setId, value in viewModel.updateRestBeforeSet(setId: setId, value: value) },
                    onRequestRestPicker: { setId, current in
                        viewModel.openRestPicker(for: setId, currentValue: current)
                        isRestPickerOpen = true
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
                .draggable(exercise.id)
                .dropDestination(for: String.self) { items, _ in
                    guard let sourceId = items.first, sourceId != exercise.id,
                          let sourceIndex = viewModel.workoutSession.exercises.firstIndex(where: { $0.id == sourceId }),
                          let targetIndex = viewModel.workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) else {
                        return false
                    }
                    viewModel.reorderExercises(from: sourceIndex, to: targetIndex)
                    return true
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if !viewModel.expandedExerciseIds.contains(exercise.id) {
                        Button(role: .destructive) {
                            viewModel.deleteExercise(exercise.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .onMove { source, destination in
                viewModel.moveExercises(from: source, to: destination)
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
                        Text(viewModel.workoutSession.dateCreated, style: .timer)
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
                showingWorkoutNotes = true
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
                pendingSelectedTemplates = []
                showingAddExercise = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview("Tracker View") {
    WorkoutTrackerView(
        viewModel: WorkoutTrackerViewModel(
            container: DevPreview.shared.container,
            workoutSession: WorkoutSessionModel.mock
        ),
        initialWorkoutSession: WorkoutSessionModel.mock
    )
    .previewEnvironment()
}
