//
//  WorkoutTrackerView.swift
//  DialedIn
//
//  Created by AI Assistant on 23/09/2025.
//

import SwiftUI

struct WorkoutTrackerView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(ExerciseHistoryManager.self) private var exerciseHistoryManager
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
	@Environment(WorkoutActivityViewModel.self) private var workoutActivityViewModel
    #endif
    @Environment(PushManager.self) private var pushManager
    @Environment(\.dismiss) private var dismiss
    
    // Session state
    @State private var workoutSession: WorkoutSessionModel
    @State private var startTime: Date = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isActive = true
    
    // UI state
    @State private var showingWorkoutNotes = false
    @State private var showingAddExercise = false
    @State private var expandedExerciseIds: Set<String> = []
    @State private var workoutNotes = ""
    @State private var currentExerciseIndex = 0
    @State private var editMode: EditMode = .inactive
    @State private var pendingSelectedTemplates: [ExerciseTemplateModel] = []
    
    // Rest timer state (independent from workout duration)
    @State private var restDurationSeconds: Int = 90
    @State private var restEndTime: Date?
    // Per-set rest mapping used when the previous set completes
    @State private var restBeforeSetIdToSec: [String: Int] = [:]
    // Rest picker presentation state
    @State private var isRestPickerOpen: Bool = false
    @State private var restPickerTargetSetId: String?
    @State private var restPickerSeconds: Int? = nil
    @State private var restPickerMinutesSelection: Int = 0
    @State private var restPickerSecondsSelection: Int = 0
    
    // Error handling
    @State private var showAlert: AnyAppAlert?
    
    // Notification identifier for rest timer
    private let restTimerNotificationId = "workout-rest-timer"

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
                    
                    if isRestActive, let restEndTime {
                        Text(timerInterval: Date()...restEndTime)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
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

extension WorkoutTrackerView {
    // MARK: - Computed Properties
    
    private var elapsedTimeString: String {
        let elapsed = Date().timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private var isRestActive: Bool {
        guard let end = restEndTime else { return false }
        return Date() < end
    }
    
    private var completedSetsCount: Int {
        workoutSession.exercises.flatMap(\.sets).filter { $0.completedAt != nil }.count
    }
    
    private var totalSetsCount: Int {
        workoutSession.exercises.flatMap(\.sets).count
    }
    
    private var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }

    private func onNotesPressed() {
        showingWorkoutNotes = true
    }

    private func buildView() {
        // Refresh from local active session to ensure persisted edits are loaded
        if let latest = try? workoutSessionManager.getLocalWorkoutSession(id: workoutSession.id) {
            workoutSession = latest
            workoutNotes = latest.notes ?? ""
        } else if let activeOpt = try? workoutSessionManager.getActiveLocalWorkoutSession() {
            if activeOpt.id == workoutSession.id {
                workoutSession = activeOpt
                workoutNotes = activeOpt.notes ?? ""
            }
        }
        // Ensure start time comes from the session creation time
        startTime = workoutSession.dateCreated
        // Ensure current exercise points to the first incomplete item
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Ensure an existing Live Activity is reused, otherwise start one
        workoutActivityViewModel.ensureLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif

        // Expand first incomplete exercise by default (fallback to first if all complete)
        if let idx = firstIncompleteExerciseIndex(in: workoutSession.exercises) {
            expandedExerciseIds.insert(workoutSession.exercises[idx].id)
        } else if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
    }

    private func discardWorkout() {
        Task {
            do {
                // Cancel any pending rest timer notifications
                await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                try workoutSessionManager.deleteLocalWorkoutSession(id: workoutSession.id)
                await MainActor.run {
                    workoutSessionManager.endActiveSession()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(
                        title: "Failed to discard workout",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }
    }

    private func computeTotalVolumeKg() -> Double {
        workoutSession.exercises.flatMap(\.sets)
            .compactMap { set in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    private func progressWidth(geometryWidth: CGFloat) -> CGFloat {
        guard totalSetsCount > 0 else { return 0 }
        let progress = Double(completedSetsCount) / Double(totalSetsCount)
        return geometryWidth * progress
    }
    
    private var isCurrentExerciseCompleted: Bool {
        guard currentExerciseIndex < workoutSession.exercises.count else { return false }
        let currentExercise = workoutSession.exercises[currentExerciseIndex]
        return areAllSetsCompleted(in: currentExercise.id)
    }
    
    private func pauseResumeWorkout() {
        isActive.toggle()
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Update activity immediately when toggling pause/resume
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    // MARK: - Exercise Management
    
    private func toggleExerciseExpansion(_ exerciseId: String) {
        if expandedExerciseIds.contains(exerciseId) {
            expandedExerciseIds.remove(exerciseId)
        } else {
            expandedExerciseIds.insert(exerciseId)
        }
    }
    
    private func moveToNextExercise() {
        if currentExerciseIndex < workoutSession.exercises.count - 1 {
            currentExerciseIndex += 1
            // Auto-expand next exercise
            let nextExercise = workoutSession.exercises[currentExerciseIndex]
            expandedExerciseIds.insert(nextExercise.id)
            
            // Optionally collapse the previous exercise
            if currentExerciseIndex > 0 {
                let previousExercise = workoutSession.exercises[currentExerciseIndex - 1]
                expandedExerciseIds.remove(previousExercise.id)
            }
        }
    }
    
    private func areAllSetsCompleted(in exerciseId: String) -> Bool {
        guard let exercise = workoutSession.exercises.first(where: { $0.id == exerciseId }) else {
            return false
        }
        
        // Return true if all sets are completed (and there's at least one set)
        return !exercise.sets.isEmpty && exercise.sets.allSatisfy { $0.completedAt != nil }
    }
    
    // MARK: - Set Management
    
    private func updateSet(_ updatedSet: WorkoutSetModel, in exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == updatedSet.id }) else {
            return
        }
        // Track completion transition (exercise-level)
        let exerciseBefore = workoutSession.exercises[exerciseIndex]
        let wasExerciseCompleteBefore = !exerciseBefore.sets.isEmpty && exerciseBefore.sets.allSatisfy { $0.completedAt != nil }

        var updatedExercises = workoutSession.exercises
        let previousCompletedAt = updatedExercises[exerciseIndex].sets[setIndex].completedAt
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet
        let isExerciseCompleteNow = !updatedExercises[exerciseIndex].sets.isEmpty && updatedExercises[exerciseIndex].sets.allSatisfy { $0.completedAt != nil }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        
        // Start a rest timer when a set transitions from incomplete -> complete
        if previousCompletedAt == nil, updatedSet.completedAt != nil {
            // Use rest defined for this set (applies after this set)
            let customForThisSet = restBeforeSetIdToSec[updatedSet.id]
            startRestTimer(durationSeconds: customForThisSet ?? restDurationSeconds)
        }
        
        // If this change completed the last set of the exercise, collapse it and expand the next
        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            if nextIndex < updatedExercises.count {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(updatedExercises[nextIndex].id)
                currentExerciseIndex = nextIndex
            } else {
                // No next exercise; just collapse the completed one
                expandedExerciseIds.remove(updatedExercises[exerciseIndex].id)
            }
        }
        
        // Always align current exercise to top-most incomplete after updates
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Update activity to reflect set/volume/progress changes
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    private func addSet(to exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = userManager.currentUser?.userId else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        let exercise = updatedExercises[exerciseIndex]
        let newIndex = exercise.sets.count + 1
        
        // Create new set based on the last set's values or default
        let lastSet = exercise.sets.last
        let newSet = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: userId,
            index: newIndex,
            reps: lastSet?.reps,
            weightKg: lastSet?.weightKg,
            durationSec: lastSet?.durationSec,
            distanceMeters: lastSet?.distanceMeters,
            rpe: lastSet?.rpe,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        )
        
        updatedExercises[exerciseIndex].sets.append(newSet)
        // Seed new set's rest with last known value
        if let last = lastKnownRestForExercise(exerciseIndex: exerciseIndex) {
            restBeforeSetIdToSec[newSet.id] = last
        }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        // Realign current exercise in case previously all-complete edge cases shift
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    private func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        // Remove any rest mapping for this set
        restBeforeSetIdToSec.removeValue(forKey: setId)
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        // Realign current exercise after deletion
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkoutProgress() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? workoutSessionManager.setActiveLocalWorkoutSession(workoutSession)
                await MainActor.run {
                    workoutSessionManager.activeSession = workoutSession
                }
            } catch {
                    showAlert = AnyAppAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Rest Timer Controls
    
    private func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        restEndTime = Date().addingTimeInterval(TimeInterval(duration))
        
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = restEndTime
        
        // Schedule local notification for when rest is complete
        if let endTime = restEndTime {
            Task {
                do {
                    try await pushManager.schedulePushNotification(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        body: "Time to get back to your workout!",
                        date: endTime
                    )
                } catch {
                    // Silently fail - notification is nice to have but not critical
                    print("Failed to schedule rest timer notification: \(error)")
                }
            }
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: "Resting",
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    private func cancelRestTimer() {
        restEndTime = nil
        
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = nil
        
        // Cancel the pending rest timer notification
        Task {
            await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
        }
        
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    private func updateWorkoutNotes() {
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        saveWorkoutProgress()
    }
    
    private func createExerciseHistoryEntries(performedAt: Date) async throws {
        guard let userId = userManager.currentUser?.userId else {
            throw NSError(domain: "WorkoutTrackerView", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create exercise history entries for each exercise in the session
        for workoutExercise in workoutSession.exercises {
            let historyEntry = ExerciseHistoryEntryModel.newEntry(
                authorId: userId,
                templateId: workoutExercise.templateId,
                templateName: workoutExercise.name,
                workoutSessionId: workoutSession.id,
                workoutExerciseId: workoutExercise.id,
                performedAt: performedAt,
                notes: workoutExercise.notes,
                sets: workoutExercise.sets
            )
            
            // Save to local storage
            try exerciseHistoryManager.addLocalExerciseHistory(entry: historyEntry)
            
            // Save to remote storage
            try await exerciseHistoryManager.createExerciseHistory(entry: historyEntry)
        }
    }
    
    private func finishWorkout() {
        Task {
            do {
                let endTime = Date()
                
                // Cancel any pending rest timer notifications
                await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                // Update session end time
                workoutSession.endSession(at: endTime)
                try workoutSessionManager.endLocalWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Save to remote
                try await workoutSessionManager.createWorkoutSession(session: workoutSession)
                try await workoutSessionManager.endWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Create exercise history entries (remote + local)
                try await createExerciseHistoryEntries(performedAt: endTime)
                
                await MainActor.run {
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    workoutActivityViewModel.endLiveActivity(session: workoutSession, success: true)
                    #endif
                    workoutSessionManager.endActiveSession()
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(title: "Failed to finish workout", subtitle: error.localizedDescription)
            }
        }
    }
    
    private func saveAndExit() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(title: "Failed to save workout", subtitle: error.localizedDescription)
            }
        }
    }

    private func addSelectedExercises() {
        guard !pendingSelectedTemplates.isEmpty, let userId = userManager.currentUser?.userId else { return }
        var updated = workoutSession.exercises
        let startIndex = updated.count
        for (offset, template) in pendingSelectedTemplates.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template.type)
            let defaultSets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: userId)
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: template.id,
                name: template.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                sets: defaultSets
            )
            updated.append(newExercise)
        }
        workoutSession.updateExercises(updated)
        // Focus to first incomplete (likely the first newly added)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        // Expand the current exercise
        if currentExerciseIndex < updated.count {
            expandedExerciseIds.removeAll()
            expandedExerciseIds.insert(updated[currentExerciseIndex].id)
        }
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                // Minimize instead of ending the session
                workoutSessionManager.minimizeActiveSession()
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .destructive) {
                showAlert = AnyAppAlert(title: "End Workout?", subtitle: "Are you sure you want to discard this workout?") {
                    AnyView(
                        VStack {
                            Button("Cancel", role: .cancel) {
                                showAlert = nil
                            }
                            Button("Discard", role: .destructive) {
                                discardWorkout()
                            }

                        }
                    )
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onNotesPressed()
            } label: {
                Image(systemName: "long.text.page.and.pencil")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                finishWorkout()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                if isRestActive {
                    cancelRestTimer()
                } else {
                    startRestTimer()
                }
            } label: {
                Image(systemName: isRestActive ? "stop" : "timer")
                    .foregroundColor(isRestActive ? .red : .accent)
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

    private func moveExercises(from source: IndexSet, to destination: Int) {
        var updated = workoutSession.exercises
        updated.move(fromOffsets: source, toOffset: destination)

        applyReorderedExercises(updated, movedFrom: source.first, movedTo: destination)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    private func reorderExercises(from sourceIndex: Int, to targetIndex: Int) {
        guard sourceIndex != targetIndex else { return }
        var updated = workoutSession.exercises
        let element = updated.remove(at: sourceIndex)
        updated.insert(element, at: targetIndex)
        applyReorderedExercises(updated, movedFrom: sourceIndex, movedTo: targetIndex)
    }

    private func applyReorderedExercises(_ updated: [WorkoutExerciseModel], movedFrom: Int?, movedTo: Int) {
        var updated = updated
        // Reindex exercises only (do not touch set indices)
        for (idx, _) in updated.enumerated() {
            updated[idx].index = idx + 1
        }

        // Always align current exercise to top-most incomplete after reorders
        workoutSession.updateExercises(updated)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        saveWorkoutProgress()
    }

    private func deleteExercise(_ exerciseId: String) {
        var updated = workoutSession.exercises
        guard let idx = updated.firstIndex(where: { $0.id == exerciseId }) else { return }
        updated.remove(at: idx)
        // Reindex remaining exercises
        for index in updated.indices { updated[index].index = index + 1 }
        workoutSession.updateExercises(updated)
        // Keep expansion state tidy
        expandedExerciseIds.remove(exerciseId)
        // Realign current exercise
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        workoutActivityViewModel.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }

    private func firstIncompleteExerciseIndex(in exercises: [WorkoutExerciseModel]) -> Int? {
        exercises.firstIndex(where: { !$0.sets.isEmpty && !$0.sets.allSatisfy { $0.completedAt != nil } })
    }

    private func syncCurrentExerciseIndexToFirstIncomplete(in exercises: [WorkoutExerciseModel]) {
        if let idx = firstIncompleteExerciseIndex(in: exercises) {
            currentExerciseIndex = idx
        } else {
            currentExerciseIndex = max(0, exercises.isEmpty ? 0 : exercises.count - 1)
        }
    }

    // Determine next set's rest seconds from per-set map
    private func nextSetRestSeconds(exerciseIndex: Int, setIndex: Int) -> Int? {
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        let nextIndex = setIndex + 1
        guard nextIndex < sets.count else { return nil }
        let nextSet = sets[nextIndex]
        return restBeforeSetIdToSec[nextSet.id]
    }

    private func lastKnownRestForExercise(exerciseIndex: Int) -> Int? {
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        // Walk from last to first to find a mapping
        for set in sets.reversed() {
            if let val = restBeforeSetIdToSec[set.id] { return val }
        }
        return nil
    }
}
