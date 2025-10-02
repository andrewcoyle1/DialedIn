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
    @Environment(\.dismiss) private var dismiss
    
    // Session state
    @State private var workoutSession: WorkoutSessionModel
    @State private var startTime: Date = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isActive = true
    
    // UI state
    @State private var showingWorkoutNotes = false
    @State private var expandedExerciseIds: Set<String> = []
    @State private var workoutNotes = ""
    @State private var currentExerciseIndex = 0
    
    // Rest timer state (independent from workout duration)
    @State private var restDurationSeconds: Int = 90
    @State private var restEndTime: Date?
    
    // Error handling
    @State private var showAlert: AnyAppAlert?

    init(workoutSession: WorkoutSessionModel) {
        self._workoutSession = State(initialValue: workoutSession)
        self._workoutNotes = State(initialValue: workoutSession.notes ?? "")
        self._startTime = State(initialValue: workoutSession.dateCreated)
    }
    
    var body: some View {
        TimelineView(.periodic(from: startTime, by: 1.0)) { _ in
            NavigationStack {
                List {
                    // Workout Overview Section
                    workoutOverviewCard
                    // Exercise Section
                    exerciseSection
                }
                // .animation(.easeInOut(duration: 0.3), value: expandedExerciseIds)
                .navigationTitle(workoutSession.name)
                .navigationBarTitleDisplayMode(.large)
                .navigationSubtitle(elapsedTimeString)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom) {
                    // Timer Header
                    timerHeaderView
                }
                .toolbar {
                    toolbarContent
                }
                .showCustomAlert(alert: $showAlert)

            }
            .onAppear {
                buildView()

            }
            .sheet(isPresented: $showingWorkoutNotes) {
                WorkoutNotesView(notes: $workoutNotes) {
                    updateWorkoutNotes()
                }
            }
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
        ForEach(Array(workoutSession.exercises.enumerated()), id: \.element.id) { index, exercise in
            Section {
                ExerciseTrackerCard(
                    exercise: exercise,
                    exerciseIndex: index,
                    isCurrentExercise: index == currentExerciseIndex,
                    isExpanded: expandedExerciseIds.contains(exercise.id),
                    onToggleExpansion: { toggleExerciseExpansion(exercise.id) },
                    onSetUpdate: { updatedSet in updateSet(updatedSet, in: exercise.id) },
                    onAddSet: { addSet(to: exercise.id) },
                    onDeleteSet: { setId in deleteSet(setId, from: exercise.id) }
                )
            } header: {
                Text(exercise.name)
            }
            .removeListRowFormatting()
        }
    }

    // MARK: - Timer Header
    private var timerHeaderView: some View {
        Button {
            if isRestActive {
                cancelRestTimer()
            } else {
                startRestTimer()
            }
        } label: {
            VStack {
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

                    Image(systemName: isRestActive ? "stop.circle.fill" : "timer")
                        .font(.title2)
                        .foregroundColor(isRestActive ? .red : .blue)
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(.glass)
        .padding(.horizontal)
    }

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

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Start Live Activity if not already started
        workoutActivityViewModel.startLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif

        // Expand first exercise by default
        if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
    }

    private func discardWorkout() {
        Task {
            do {
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
        
        var updatedExercises = workoutSession.exercises
        let previousCompletedAt = updatedExercises[exerciseIndex].sets[setIndex].completedAt
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        
        // Start a rest timer when a set transitions from incomplete -> complete
        if previousCompletedAt == nil, updatedSet.completedAt != nil {
            startRestTimer()
        }
        
        // Check if all sets in current exercise are completed and move to next exercise
        if exerciseIndex == currentExerciseIndex && areAllSetsCompleted(in: exerciseId) {
            moveToNextExercise()
        }

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
        workoutSession.updateExercises(updatedExercises)
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
    
    private func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
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
