//
//  WorkoutTrackerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import HealthKit

@Observable
@MainActor
class WorkoutTrackerViewModel {
    // MARK: - Dependencies
    
    let userManager: UserManager
    let workoutSessionManager: WorkoutSessionManager
    let exerciseHistoryManager: ExerciseHistoryManager
    let unitPreferenceManager: ExerciseUnitPreferenceManager
    let logManager: LogManager
    let pushManager: PushManager
    
    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    let hkWorkoutManager: HKWorkoutManager
    let workoutActivityViewModel: WorkoutActivityViewModel
    #endif
    
    // MARK: - State Properties
    
    var workoutSession: WorkoutSessionModel
    var startTime: Date
    var elapsedTime: TimeInterval = 0
    var isActive = true
    
    var expandedExerciseIds: Set<String> = []
    var workoutNotes = ""
    var currentExerciseIndex = 0
    
    var exerciseUnitPreferences: [String: ExerciseUnitPreference] = [:]
    var previousWorkoutSession: WorkoutSessionModel?
    
    var restDurationSeconds: Int = 90
    var restBeforeSetIdToSec: [String: Int] = [:]
    
    var showAlert: AnyAppAlert?
    
    var restPickerTargetSetId: String?
    var restPickerSeconds: Int?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0
    
    // Internal timers
    var widgetSyncTimer: Timer?
    
    // Notification identifier for rest timer
    private let restTimerNotificationId = "workout-rest-timer"
    
    var restEndTime: Date? {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        return hkWorkoutManager.restEndTime
        #else
        return nil
        #endif
    }
    
    // MARK: - Initialization
    
    init(
        container: DependencyContainer,
        workoutSession: WorkoutSessionModel
    ) {
        
        self.userManager = container.resolve(UserManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.exerciseHistoryManager = container.resolve(ExerciseHistoryManager.self)!
        self.unitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.hkWorkoutManager = container.resolve(HKWorkoutManager.self)!
        self.workoutActivityViewModel = container.resolve(WorkoutActivityViewModel.self)!
        #endif
        
        self.workoutSession = workoutSession
        self.workoutNotes = workoutSession.notes ?? ""
        self.startTime = workoutSession.dateCreated
    }
    
    // MARK: - Computed Properties
    
    var elapsedTimeString: String {
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
    
    var isRestActive: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard let end = hkWorkoutManager.restEndTime else { return false }
        return Date() < end
        #else
        return false
        #endif
    }
    
    var completedSetsCount: Int {
        workoutSession.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
    }
    
    var totalSetsCount: Int {
        workoutSession.exercises.flatMap { $0.sets }.count
    }
    
    var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }
    
    // MARK: - Lifecycle
    
    func onAppear() async {
        buildView()
        loadUnitPreferences()
        startWidgetSyncTimer()
        
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
        
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Configure and start HK session for strength training
        hkWorkoutManager.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        hkWorkoutManager.startWorkout(workout: workoutSession)
        #endif
    }
    
    func onScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        if newPhase == .active && oldPhase == .background {
            print("📱 App returned to foreground, syncing widget completions and refreshing view")
            syncPendingSetCompletionFromWidget()
            buildView()
        }
    }
    
    func buildView() {
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
            restEndsAt: hkWorkoutManager.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif

        // Expand first incomplete exercise by default (fallback to first if all complete)
        if let idx = firstIncompleteExerciseIndex(in: workoutSession.exercises) {
            expandedExerciseIds.insert(workoutSession.exercises[idx].id)
        } else if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
        
        // Check for pending widget completions that happened while backgrounded
        syncPendingSetCompletionFromWidget()
    }
    
    // MARK: - Unit Preferences
    
    func loadUnitPreferences() {
        // Load unit preferences for all exercises in the workout
        for exercise in workoutSession.exercises {
            let preference = unitPreferenceManager.getPreference(for: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = preference
        }
        
        // Load previous workout session for "Prev" column
        loadPreviousWorkoutSession()
    }
    
    func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        unitPreferenceManager.setWeightUnit(unit, for: templateId)
        // Update local cache
        if var preference = exerciseUnitPreferences[templateId] {
            preference.weightUnit = unit
            exerciseUnitPreferences[templateId] = preference
        } else {
            exerciseUnitPreferences[templateId] = unitPreferenceManager.getPreference(for: templateId)
        }
    }
    
    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        unitPreferenceManager.setDistanceUnit(unit, for: templateId)
        // Update local cache
        if var preference = exerciseUnitPreferences[templateId] {
            preference.distanceUnit = unit
            exerciseUnitPreferences[templateId] = preference
        } else {
            exerciseUnitPreferences[templateId] = unitPreferenceManager.getPreference(for: templateId)
        }
    }
    
    // MARK: - Previous Values
    
    func loadPreviousWorkoutSession() {
        // Only load previous session if this workout is from a template
        guard let templateId = workoutSession.workoutTemplateId,
              let authorId = userManager.currentUser?.userId else {
            previousWorkoutSession = nil
            return
        }
        
        Task {
            do {
                previousWorkoutSession = try await workoutSessionManager.getLastCompletedSessionForTemplate(
                    templateId: templateId,
                    authorId: authorId
                )
            } catch {
                print("Failed to load previous workout session: \(error)")
                previousWorkoutSession = nil
            }
        }
    }
    
    func buildPreviousLookup(for exercise: WorkoutExerciseModel) -> [Int: WorkoutSetModel] {
        guard let prevSession = previousWorkoutSession else { return [:] }
        
        // Find matching exercise by templateId
        guard let prevExercise = prevSession.exercises.first(where: { $0.templateId == exercise.templateId }) else {
            return [:]
        }
        
        // Map sets by index
        return Dictionary(uniqueKeysWithValues: prevExercise.sets.map { ($0.index, $0) })
    }
    
    // MARK: - Workout Actions
    
    func discardWorkout(onDismiss: @escaping () -> Void) {
        stopWidgetSyncTimer()
        Task {
            do {
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                hkWorkoutManager.endWorkout()
                #endif
                
                // Cancel any pending rest timer notifications
                await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End live activity with immediate dismissal for discarded workouts
                workoutActivityViewModel.endLiveActivity(session: workoutSession, isCompleted: false)
                #endif
                
                try workoutSessionManager.deleteLocalWorkoutSession(id: workoutSession.id)
                // Don't mark scheduled workout as complete when discarding
                await workoutSessionManager.endActiveSession(markScheduledComplete: false)
                await MainActor.run {
                    onDismiss()
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
    
    func finishWorkout(onDismiss: @escaping () -> Void) {
        stopWidgetSyncTimer()
        Task {
            do {
                logManager.trackEvent(
                    eventName: "finish_workout_debug",
                    parameters: [
                        "session_id": workoutSession.id,
                        "template_id": workoutSession.workoutTemplateId ?? "nil",
                        "scheduled_id": workoutSession.scheduledWorkoutId ?? "nil",
                        "plan_id": workoutSession.trainingPlanId ?? "nil"
                    ],
                    type: .info
                )
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                hkWorkoutManager.endWorkout()
                #endif
                
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
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                workoutActivityViewModel.endLiveActivity(session: workoutSession, isCompleted: true)
                #endif
                await workoutSessionManager.endActiveSession()
                await MainActor.run {
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(title: "Failed to finish workout", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    func updateWorkoutNotes() {
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        saveWorkoutProgress()
    }
    
    func updateExerciseNotes(_ notes: String, for exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
    }
    
    func minimizeSession(onDismiss: @escaping () -> Void) {
        workoutSessionManager.minimizeActiveSession()
        onDismiss()
    }
    
    // MARK: - Rest Timer
    
    func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        hkWorkoutManager.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = hkWorkoutManager.restEndTime
        
        // Schedule local notification for when rest is complete
        if let endTime = hkWorkoutManager.restEndTime {
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
        #endif
    }
    
    func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        hkWorkoutManager.cancelRest()
        #endif
        
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = nil
        
        // Cancel the pending rest timer notification
        Task {
            await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
        }
    }
    
    func saveRestPickerValue() {
        let seconds = (restPickerMinutesSelection * 60) + restPickerSecondsSelection
        if let setId = restPickerTargetSetId {
            restBeforeSetIdToSec[setId] = seconds
        }
    }
    
    func openRestPicker(for setId: String, currentValue: Int?) {
        restPickerTargetSetId = setId
        restPickerSeconds = currentValue
        let total = currentValue ?? restDurationSeconds
        restPickerMinutesSelection = max(0, total / 60)
        restPickerSecondsSelection = max(0, total % 60)
    }
    
    func updateRestBeforeSet(setId: String, value: Int?) {
        if let value = value {
            restBeforeSetIdToSec[setId] = value
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }
    
    func getRestBeforeSet(setId: String) -> Int? {
        restBeforeSetIdToSec[setId]
    }
    
    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        Task {
            do {
                try workoutSessionManager.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? workoutSessionManager.setActiveLocalWorkoutSession(workoutSession)
                await MainActor.run {
                    workoutSessionManager.activeSession = workoutSession
                }
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    private func createExerciseHistoryEntries(performedAt: Date) async throws {
        guard let userId = userManager.currentUser?.userId else {
            throw NSError(domain: "WorkoutTrackerViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
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
    
    // MARK: - Helpers
    
    func computeTotalVolumeKg() -> Double {
        workoutSession.exercises.flatMap { $0.sets }
            .compactMap { set in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    private func firstIncompleteExerciseIndex(in exercises: [WorkoutExerciseModel]) -> Int? {
        exercises.firstIndex(where: { !$0.sets.isEmpty && !$0.sets.allSatisfy { $0.completedAt != nil } })
    }

    func syncCurrentExerciseIndexToFirstIncomplete(in exercises: [WorkoutExerciseModel]) {
        let oldIndex = currentExerciseIndex
        if let idx = firstIncompleteExerciseIndex(in: exercises) {
            currentExerciseIndex = idx
        } else {
            currentExerciseIndex = max(0, exercises.isEmpty ? 0 : exercises.count - 1)
        }
        if oldIndex != currentExerciseIndex {
            print("🔄 Current exercise index changed: \(oldIndex) → \(currentExerciseIndex) (reason: sync to first incomplete)")
        }
    }
    
    func applyReorderedExercises(_ updated: [WorkoutExerciseModel], movedFrom: Int?, movedTo: Int) {
        var updated = updated
        // Reindex exercises only (do not touch set indices)
        for idx in updated.indices {
            updated[idx].index = idx + 1
        }

        // Always align current exercise to top-most incomplete after reorders
        workoutSession.updateExercises(updated)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        saveWorkoutProgress()
    }
    
    func lastKnownRestForExercise(exerciseIndex: Int) -> Int? {
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        // Walk from last to first to find a mapping
        for set in sets.reversed() {
            if let val = restBeforeSetIdToSec[set.id] { return val }
        }
        return nil
    }
}
