//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI
import HealthKit

struct WorkoutTrackerView: View {
    @Environment(UserManager.self) var userManager
    @Environment(WorkoutSessionManager.self) var workoutSessionManager
    @Environment(ExerciseHistoryManager.self) var exerciseHistoryManager
    @Environment(HKWorkoutManager.self) var hkWorkoutManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    @Environment(WorkoutActivityViewModel.self) var workoutActivityViewModel
    #endif
    @Environment(PushManager.self) var pushManager
    @Environment(\.dismiss) var dismiss
    
    // Session state
    @State var workoutSession: WorkoutSessionModel
    @State var startTime: Date = Date()
    @State var elapsedTime: TimeInterval = 0
    @State var timer: Timer?
    @State var isActive = true
    
    // UI state
    @State var showingWorkoutNotes = false
    @State var showingAddExercise = false
    @State var expandedExerciseIds: Set<String> = []
    @State var workoutNotes = ""
    @State var currentExerciseIndex = 0
    @State var editMode: EditMode = .inactive
    @State var pendingSelectedTemplates: [ExerciseTemplateModel] = []
    
    // Rest timer state (independent from workout duration)
    @State var restDurationSeconds: Int = 90
    // Per-set rest mapping used when the previous set completes
    @State var restBeforeSetIdToSec: [String: Int] = [:]
    // Rest picker presentation state
    @State var isRestPickerOpen: Bool = false
    @State var restPickerTargetSetId: String?
    @State var restPickerSeconds: Int?
    @State var restPickerMinutesSelection: Int = 0
    @State var restPickerSecondsSelection: Int = 0
    
    // Error handling
    @State var showAlert: AnyAppAlert?
    
    // Notification identifier for rest timer
    let restTimerNotificationId = "workout-rest-timer"

    init(workoutSession: WorkoutSessionModel) {
        self._workoutSession = State(initialValue: workoutSession)
        self._workoutNotes = State(initialValue: workoutSession.notes ?? "")
        self._startTime = State(initialValue: workoutSession.dateCreated)
    }
    
    var body: some View {
        TimelineView(.periodic(from: startTime, by: 1.0)) { _ in
            NavigationStack {
                ZStack {
                    List {
                    // Workout Overview Section
                    workoutOverviewCard
                    
                    // Exercise Section
                    exerciseSection
                    }
                }
                .navigationTitle(workoutSession.name)
                .navigationBarTitleDisplayMode(.large)
                .navigationSubtitle(elapsedTimeString)
                .scrollIndicators(.hidden)
                .environment(\.editMode, $editMode)
                .toolbar {
                    toolbarContent
                }
                .safeAreaInset(edge: .bottom) {
                    // Timer Header
                    timerHeaderView()
                }
                .showCustomAlert(alert: $showAlert)
            }
            .onAppear {
                buildView()
                Task {
                    // Ensure HealthKit authorization before starting HK session
                    let healthKitManager = HealthKitManager()
                    if healthKitManager.canRequestAuthorisation() && healthKitManager.needsAuthorisationForRequiredTypes() {
                        do {
                            try await healthKitManager.requestAuthorization()
                        } catch {
                            print("HealthKit authorization failed: \(error)")
                        }
                    }
                    // Verify workout write permission before starting
                    guard !HealthKitService().needsAuthorisationForRequiredTypes() else {
                        print("Skipping HKWorkoutSession start: missing HealthKit authorization")
                        return
                    }
                    // Configure and start HK session for strength training
                    hkWorkoutManager.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
                    hkWorkoutManager.startWorkout(workout: workoutSession)
                }
            }
            .showModal(showModal: $isRestPickerOpen) {
                CustomModalView(
                    title: "Set Rest",
                    subtitle: nil,
                    primaryButtonTitle: "Save",
                    primaryButtonAction: {
                        let seconds = (restPickerMinutesSelection * 60) + restPickerSecondsSelection
                        if let setId = restPickerTargetSetId {
                            // Update mapping in-place (mirrors onRestBeforeChange behavior)
                            restBeforeSetIdToSec[setId] = seconds
                        }
                        isRestPickerOpen = false
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: { isRestPickerOpen = false },
                    middleContent: AnyView(
                        HStack(spacing: 16) {
                            Picker("Minutes", selection: $restPickerMinutesSelection) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute) m").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Picker("Seconds", selection: $restPickerSecondsSelection) {
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
                WorkoutNotesView(notes: $workoutNotes) {
                    updateWorkoutNotes()
                }
            }
            .sheet(isPresented: $showingAddExercise, onDismiss: {
                addSelectedExercises()
            }, content: {
                AddExerciseModal(selectedExercises: $pendingSelectedTemplates)
            })
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

                        Text("\(workoutSession.exercises.count) exercises")
                            .font(.headline)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Sets Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(completedSetsCount)/\(totalSetsCount)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }

                // Quick stats
                HStack(spacing: 20) {
                    StatItem(title: "Exercise", value: "\(currentExerciseIndex + 1)/\(workoutSession.exercises.count)")
                    StatItem(title: "Volume", value: formattedVolume)
                    if !workoutNotes.isEmpty {
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
            ForEach(workoutSession.exercises, id: \.id) { exercise in
                let index = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                ExerciseTrackerCard(
                    exercise: exercise,
                    exerciseIndex: index,
                    isCurrentExercise: index == currentExerciseIndex,
                    onSetUpdate: { updatedSet in updateSet(updatedSet, in: exercise.id) },
                    onAddSet: { addSet(to: exercise.id) },
                    onDeleteSet: { setId in deleteSet(setId, from: exercise.id) },
                    onHeaderLongPress: { /* no-op: reordering via drag on header */ },
                    onNotesChange: { notes in updateExerciseNotes(notes, for: exercise.id) },
                    restBeforeSecForSet: { setId in restBeforeSetIdToSec[setId] },
                    onRestBeforeChange: { setId, value in restBeforeSetIdToSec[setId] = value ?? 0; if value == nil { restBeforeSetIdToSec.removeValue(forKey: setId) } },
                    onRequestRestPicker: { setId, current in
                        restPickerTargetSetId = setId
                        restPickerSeconds = current
                        // Pre-seed pickers
                        let total = current ?? restDurationSeconds
                        restPickerMinutesSelection = max(0, total / 60)
                        restPickerSecondsSelection = max(0, total % 60)
                        isRestPickerOpen = true
                    },
                    isExpanded: Binding(
                        get: { expandedExerciseIds.contains(exercise.id) },
                        set: { newValue in
                            if newValue {
                                // Allow only one expanded at a time: collapse current first
                                expandedExerciseIds.removeAll()
                                expandedExerciseIds.insert(exercise.id)
                            } else {
                                expandedExerciseIds.remove(exercise.id)
                            }
                        }
                    )
                )
                .draggable(exercise.id)
                .dropDestination(for: String.self) { items, _ in
                    guard let sourceId = items.first, sourceId != exercise.id,
                          let sourceIndex = workoutSession.exercises.firstIndex(where: { $0.id == sourceId }),
                          let targetIndex = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) else {
                        return false
                    }
                    reorderExercises(from: sourceIndex, to: targetIndex)
                    return true
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if !expandedExerciseIds.contains(exercise.id) {
                        Button(role: .destructive) {
                            deleteExercise(exercise.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .onMove(perform: moveExercises)
        } header: {
            Text("Exercises")
        }
    }
    
    // MARK: - Timer Header
    @ViewBuilder
    private func timerHeaderView() -> some View {
        if isRestActive {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRestActive ? "Rest Timer" : "Workout Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let end = hkWorkoutManager.restEndTime {
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
                        Text(workoutSession.dateCreated, style: .timer)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(.bar)
        }
    }
}

// MARK: - Workout Notes View

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
    WorkoutTrackerView(workoutSession: WorkoutSessionModel.mock)
        .previewEnvironment()
}

#Preview("Workout Notes View") {

    Text("Hello")
        .sheet(isPresented: Binding.constant(true)) {
            WorkoutNotesView(notes: Binding.constant("")) {
            // Implement save action for preview if needed
        }
    }
}

// Extracted logic moved to `WorkoutTrackerView+Logic.swift`
