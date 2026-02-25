//
//  WorkoutTrackerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import HealthKit

@Observable
@MainActor
class WorkoutTrackerPresenter {

    let interactor: WorkoutTrackerInteractor
    let router: WorkoutTrackerRouter

    // MARK: - State Properties
    var workoutSession: WorkoutSessionModel
    var restDurationSeconds: Int = 90
    var restBeforeSetIdToSec: [String: Int] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0

    var pendingSelectedTemplates: [ExerciseModel] = []

    var editMode: EditMode = .inactive
    
    var startTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var isActive = true
    
    var expandedExerciseIds: Set<String> = []
    var workoutNotes = ""
    var currentExerciseIndex = 0
    
    var previousWorkoutSession: WorkoutSessionModel?
    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]

    // Internal timers
    var widgetSyncTimer: Timer?
    
    // Notification identifier for rest timer
    let restTimerNotificationId = "workout-rest-timer"
    
    var restEndTime: Date? {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        return interactor.restEndTime
        #else
        return nil
        #endif
    }
    
    var exercisesCount: String {
        "\(workoutSession.exercises.count) exercises"
    }
    
    var exerciseFraction: String {
        "\(currentExerciseIndex + 1)/\(workoutSession.exercises.count)"
    }
    
    var completedSetsFraction: String {
        "\(completedSetsCount)/\(totalSetsCount)"
    }
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    // MARK: - Initialization
    
    init(
        interactor: WorkoutTrackerInteractor,
        router: WorkoutTrackerRouter
    ) {
        self.interactor = interactor
        self.router = router
        
        if let session = interactor.activeSession {
            self.workoutSession = session
            loadUnitPreferences()
        } else {
            self.workoutSession = WorkoutSessionModel(authorId: UUID().uuidString, template: .mock)
            loadUnitPreferences()
        }
    }
    
    func loadWorkoutSession(_ workoutSessionId: String) async {
        do {
            self.workoutSession = try interactor.getLocalWorkoutSession(id: workoutSessionId)
        } catch let localError {
            print("⚠️ Failed to load workout session locally: \(localError.localizedDescription)")
            do {
                self.workoutSession = try await interactor.getWorkoutSession(id: workoutSessionId)
            } catch let remoteError {
                print("⚠️ Failed to load workout session remotely: \(remoteError.localizedDescription)")
                // Only show error if we don't already have a valid session from activeSession
                if workoutSession.id != workoutSessionId {
                    router.showSimpleAlert(title: "Failed to load workout session", subtitle: "Please try again")
                }
            }
        }
        self.workoutNotes = workoutSession.notes ?? ""
        self.startTime = workoutSession.dateCreated
        // Load unit preferences for all exercises
        loadUnitPreferences()
        // Refresh from local storage to ensure latest persisted changes are loaded
        buildView()
    }
    
    func loadUnitPreferences() {
        exerciseUnitPreferences.removeAll(keepingCapacity: true)
        for exercise in workoutSession.exercises {
            let preference = interactor.getPreference(templateId: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = (
                weightUnit: preference.weightUnit,
                distanceUnit: preference.distanceUnit
            )
        }
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
        guard let end = interactor.restEndTime else { return false }
        return Date() < end
        #else
        return false
        #endif
    }
    
    var completedSetsCount: Int {
        return workoutSession.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
    }
    
    var totalSetsCount: Int {
        return workoutSession.exercises.flatMap { $0.sets }.count
    }
    
    var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }

    // MARK: - Display Settings

    var showWorkoutTimer: Bool { interactor.workoutSettings.showWorkoutTimer }
    var showBodyweightContribution: Bool { interactor.workoutSettings.showBodyweightContribution }
    var showRIRTracking: Bool { interactor.workoutSettings.rirTracking }

    // MARK: - Lifecycle
    @MainActor
    deinit {
        stopWidgetSyncTimer()
    }
    
    func onAppear() async {
        print("📥 WorkoutTrackerPresenter.onAppear() for session id=\(workoutSession.id)")
        buildView()
        startWidgetSyncTimer()
        
        // Ensure HealthKit authorization before starting HK session
        let healthKitManager = HealthKitManager()
        if healthKitManager.canRequestAuthorisation() && healthKitManager.needsAuthorisationForRequiredTypes() {
            do {
                try await healthKitManager.requestAuthorisation()
            } catch {
                print("HealthKit authorization failed: \(error)")
            }
        }
        
        // Apply keep-alive setting
        UIApplication.shared.isIdleTimerDisabled = interactor.workoutSettings.keepAlive

        // Verify workout write permission before starting
        guard !HealthKitService().needsAuthorisationForRequiredTypes() else {
            print("Skipping HKWorkoutSession start: missing HealthKit authorization")
            return
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Avoid starting the same HK workout session multiple times for this workout.
        if SharedWorkoutStorage.hkStartedSessionId == workoutSession.id {
            print("⏭️ Skipping HK start; already started for session id=\(workoutSession.id)")
            return
        }
        
        let currentHKState = interactor.workoutSessionState
        print("📊 HK state in onAppear for session \(workoutSession.id): \(String(describing: currentHKState)))")
        // Configure and start HK session for strength training
        print("📱 WorkoutTrackerPresenter: Configuring HK session for strength training")
        interactor.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        print("📱 WorkoutTrackerPresenter: About to call hkWorkoutManager.startWorkout()")
        interactor.startWorkout(workout: workoutSession)
        print("📱 WorkoutTrackerPresenter: hkWorkoutManager.startWorkout() completed")
        SharedWorkoutStorage.hkStartedSessionId = workoutSession.id
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
        print("🏗️ WorkoutTrackerPresenter.buildView() starting for session id=\(workoutSession.id)")
        // Refresh from local active session to ensure persisted edits are loaded
        if let latest = try? interactor.getLocalWorkoutSession(id: workoutSession.id) {
            self.workoutSession = latest
            workoutNotes = latest.notes ?? ""
            workoutSession = latest
        } else if let activeOpt = try? interactor.getActiveLocalWorkoutSession() {
            if activeOpt.id == workoutSession.id {
                self.workoutSession = activeOpt
                workoutNotes = activeOpt.notes ?? ""
                workoutSession = activeOpt
            }
        }
        // Ensure start time comes from the session creation time
        startTime = workoutSession.dateCreated
        // Ensure current exercise points to the first incomplete item
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Ensure an existing Live Activity is reused, otherwise start one
        interactor.ensureLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
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

        // Strip incomplete warmup sets if the setting is off
        applyWarmupSetting()

        print("✅ WorkoutTrackerPresenter.buildView() completed; exercises=\(workoutSession.exercises.count), currentExerciseIndex=\(currentExerciseIndex)")
    }

    private func applyWarmupSetting() {
        guard !interactor.workoutSettings.addSmartWarmUps else { return }
        var updated = workoutSession.exercises
        var changed = false
        for index in updated.indices {
            let before = updated[index].sets.count
            updated[index].sets.removeAll { $0.isWarmup && $0.completedAt == nil }
            if updated[index].sets.count != before {
                for jindex in updated[index].sets.indices { updated[index].sets[jindex].index = jindex + 1 }
                changed = true
            }
        }
        guard changed else { return }
        workoutSession.updateExercises(updated)
        saveWorkoutProgress()
    }
            
    // MARK: - Previous Values
    
    func loadPreviousWorkoutSession() {
        // Only load previous session if this workout is from a template
        guard let templateId = workoutSession.workoutTemplateId,
              let authorId = interactor.currentUser?.userId else {
            previousWorkoutSession = nil
            return
        }
        
        Task {
            do {
                previousWorkoutSession = try await interactor.getLastCompletedSessionForTemplate(
                    templateId: templateId,
                    authorId: authorId
                )
            } catch {
                print("Failed to load previous workout session: \(error)")
                previousWorkoutSession = nil
            }
        }
    }

    func getUnitPreference(for templateId: String) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = interactor.getPreference(templateId: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
    }
    
    func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.weightUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setWeightUnit(unit, for: templateId)
    }
    
    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        var current = getUnitPreference(for: templateId)
        current.distanceUnit = unit
        exerciseUnitPreferences[templateId] = current
        interactor.setDistanceUnit(unit, for: templateId)
    }
    
    /// Shows a prompt asking whether to just change display unit or convert values
    func promptWeightUnitChange(_ newUnit: ExerciseWeightUnit, for exercise: WorkoutExerciseModel) {
        let currentUnit = getUnitPreference(for: exercise.templateId).weightUnit
        
        // If same unit, no need to prompt
        guard newUnit != currentUnit else {
            return
        }
        
        router.showAlert(
            title: "Change Weight Unit",
            subtitle: "How would you like to change the unit for '\(exercise.name)'?",
            buttons: {
                AnyView(
                    VStack(spacing: 8) {
                        Button("Display Only") {
                            // Just update the preference, don't convert values
                            self.updateWeightUnit(newUnit, for: exercise.templateId)
                        }
                        
                        Button("Convert Values") {
                            // Convert weights to new unit, round to equipment increments, and update session
                            self.convertAndRoundWeights(to: newUnit, for: exercise)
                        }
                        
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
    }
    
    /// Shows a prompt asking whether to just change display unit or convert values
    func promptDistanceUnitChange(_ newUnit: ExerciseDistanceUnit, for exercise: WorkoutExerciseModel) {
        let currentUnit = getUnitPreference(for: exercise.templateId).distanceUnit
        
        // If same unit, no need to prompt
        guard newUnit != currentUnit else {
            return
        }
        
        router.showAlert(
            title: "Change Distance Unit",
            subtitle: "How would you like to change the unit for '\(exercise.name)'?",
            buttons: {
                AnyView(
                    VStack(spacing: 8) {
                        Button("Display Only") {
                            // Just update the preference, don't convert values
                            self.updateDistanceUnit(newUnit, for: exercise.templateId)
                        }
                        
                        Button("Convert Values") {
                            // Convert distances to new unit and update session
                            self.convertAndRoundDistances(to: newUnit, for: exercise)
                        }
                        
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
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
    
    func discardWorkout() {
        stopWidgetSyncTimer()
        Task {
            do {
                try? await Task.sleep(for: .seconds(1))
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                interactor.endWorkout()
                #endif

                // Cancel any pending rest timer notifications
//                await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])

                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End live activity with immediate dismissal for discarded workouts
                interactor.endLiveActivity(session: workoutSession, isCompleted: false, statusMessage: "Workout Discarded")
                #endif

                try interactor.deleteLocalWorkoutSession(id: workoutSession.id)
                // Don't mark scheduled workout as complete when discarding
                UIApplication.shared.isIdleTimerDisabled = false
                SharedWorkoutStorage.clearHKStartedSessionId()
                await interactor.endActiveSession(markScheduledComplete: false)
                router.dismissScreen()

            } catch {
                await MainActor.run {
                    self.router.showSimpleAlert(
                        title: "Failed to discard workout",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }

    }

    func onDiscardWorkoutPressed() {
        router.showAlert(
            title: "End Workout?",
            subtitle: "Are you sure you want to discard this workout?"
        ) {
            AnyView(
                VStack {
                    Button("Cancel", role: .cancel) {
                    }
                    Button("Discard", role: .destructive) {
                        self.discardWorkout()
                    }
                }
            )
        }
    }

    func minimizeSession() {
        stopWidgetSyncTimer()
        router.dismissScreen()
    }
    
    // MARK: - Rest Timer
    
    func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        interactor.cancelRest()
        #endif
        
        // Cancel the pending rest timer notification
//        Task {
//            await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
//        }
    }
            
    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        Task {
            do {
                try interactor.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? interactor.setActiveLocalWorkoutSession(workoutSession)
            } catch {
                await MainActor.run {
                    self.router.showSimpleAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func computeTotalVolumeKg() -> Double {
        return workoutSession.exercises.flatMap { $0.sets }
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
        self.workoutSession = workoutSession
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        saveWorkoutProgress()
    }
        
    func presentWorkoutNotes() {
        router.showWorkoutNotesView(
            delegate: WorkoutNotesDelegate(
                notes: Binding(
                    get: {
                        self.workoutNotes
                    },
                    set: { newValue in
                        self.workoutNotes = newValue
                    }
                ),
                onSave: {
                    self.updateWorkoutNotes()
                }
            )
        )
    }
    
    private func updateWorkoutNotes() {
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        self.workoutSession = workoutSession
        saveWorkoutProgress()
    }
    
    func presentAddExercise() {
        router.showExercisePickerView(
            delegate: ExercisePickerDelegate(
                selectedExercises: Binding(
                    get: { self.pendingSelectedTemplates },
                    set: { self.pendingSelectedTemplates = $0 }
                )
            )
        )
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
