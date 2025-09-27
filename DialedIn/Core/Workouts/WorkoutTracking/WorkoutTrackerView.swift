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
    @Environment(\.dismiss) private var dismiss
    
    // Session state
    @State private var workoutSession: WorkoutSessionModel
    @State private var startTime: Date = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isActive = true
    
    // UI state
    @State private var showingEndWorkoutAlert = false
    @State private var showingWorkoutNotes = false
    @State private var expandedExerciseIds: Set<String> = []
    @State private var workoutNotes = ""
    @State private var currentExerciseIndex = 0
    
    // Rest timer state (independent from workout duration)
    @State private var restDurationSeconds: Int = 90
    @State private var restStartTime: Date?
    @State private var restEndTime: Date?
    
    // Error handling
    @State private var errorMessage: String?
    @State private var showingError = false
    
    init(workoutSession: WorkoutSessionModel) {
        self._workoutSession = State(initialValue: workoutSession)
        self._workoutNotes = State(initialValue: workoutSession.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Workout Overview
                    workoutOverviewCard
                    
                } header: {
                    Text("Workout Overview")
                }
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
            // .animation(.easeInOut(duration: 0.3), value: expandedExerciseIds)
            .navigationTitle(workoutSession.name)
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(formattedElapsedTime)
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                // Timer Header
                timerHeaderView
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        showingEndWorkoutAlert = true
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
                
                // Next Exercise button (only shown if current exercise is completed and there's a next exercise)
                if isCurrentExerciseCompleted && currentExerciseIndex < workoutSession.exercises.count - 1 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            moveToNextExercise()
                        } label: {
                            HStack {
                                Text("Next Exercise")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .onAppear {
            startTimer()
            // Expand first exercise by default
            if let firstExercise = workoutSession.exercises.first {
                expandedExerciseIds.insert(firstExercise.id)
            }
        }
        .onDisappear {
            stopTimer()
        }
        .alert("End Workout?", isPresented: $showingEndWorkoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Save & Exit") {
                saveAndExit()
            }
        } message: {
            Text("Do you want to save your progress or discard this workout?")
        }
        .sheet(isPresented: $showingWorkoutNotes) {
            WorkoutNotesView(notes: $workoutNotes) {
                updateWorkoutNotes()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred")
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
                        
                        if isRestActive {
                            Text(formattedRestRemaining)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        } else {
                            Text(formattedElapsedTime)
                                .font(.title2.bold())
                                .foregroundColor(isActive ? .primary : .orange)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isRestActive ? "stop.circle.fill" : "timer")
                        .font(.title2)
                        .foregroundColor(isRestActive ? .red : .blue)
                }
                if let interval = restTimerInterval {
                    ProgressView(timerInterval: interval, countsDown: true).progressViewStyle(.linear)
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(.glass)
        .padding(.horizontal)
    }
    
    // MARK: - Workout Overview Card
    
    private var workoutOverviewCard: some View {
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
    }
    
    // MARK: - Helper Views
    
    private struct StatItem: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.footnote.bold())
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
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
    
    private var restTimerInterval: ClosedRange<Date>? {
        guard let start = restStartTime, let end = restEndTime, Date() < end else { return nil }
        return start...end
    }
    
    private var formattedRestRemaining: String {
        guard let end = restEndTime else { return "Ready" }
        let remaining = max(0, Int(ceil(end.timeIntervalSinceNow)))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var completedSetsCount: Int {
        workoutSession.exercises.flatMap(\.sets).filter { $0.completedAt != nil }.count
    }
    
    private var totalSetsCount: Int {
        workoutSession.exercises.flatMap(\.sets).count
    }
    
    private var formattedVolume: String {
        let totalVolume = workoutSession.exercises.flatMap(\.sets)
            .compactMap { set in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            
            .reduce(0.0, { $0 + $1 })
        
        return String(format: "%.0f kg", totalVolume)
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
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isActive {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func pauseResumeWorkout() {
        isActive.toggle()
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
    }
    
    private func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        // Reindex remaining sets
        for (index, _) in updatedExercises[exerciseIndex].sets.enumerated() {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkoutProgress() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save progress: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    // MARK: - Rest Timer Controls
    
    private func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        restStartTime = Date()
        restEndTime = Date().addingTimeInterval(TimeInterval(duration))
    }
    
    private func cancelRestTimer() {
        restStartTime = nil
        restEndTime = nil
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
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to finish workout: \(error.localizedDescription)"
                    showingError = true
                }
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
                await MainActor.run {
                    errorMessage = "Failed to save workout: \(error.localizedDescription)"
                    showingError = true
                }
            }
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

#Preview {
    WorkoutTrackerView(workoutSession: WorkoutSessionModel.mock)
        .previewEnvironment()
}
