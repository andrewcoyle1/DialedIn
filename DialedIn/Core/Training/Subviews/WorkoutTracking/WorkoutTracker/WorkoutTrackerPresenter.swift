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
    var workoutSession: WorkoutSessionModel {
        didSet { saveWorkoutProgress() }
    }
    
    var restDurationSeconds: Int { interactor.workoutSettings.defaultRestDurationSeconds }
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
        
        self.workoutSession = interactor.activeSession ?? WorkoutSessionModel(
            authorId: "",
            name: "",
            dateCreated: .now,
            exercises: []
        )
        loadUnitPreferences()
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
        buildView()
        startWidgetSyncTimer()
        
        // Ensure HealthKit authorization before starting HK session
        let healthKitManager = HealthKitManager()
        if healthKitManager.canRequestAuthorisation() && healthKitManager.needsAuthorisationForRequiredTypes() {
            do {
                try await healthKitManager.requestAuthorisation()
            } catch { }
        }
        
        // Apply keep-alive setting
        UIApplication.shared.isIdleTimerDisabled = interactor.workoutSettings.keepAlive

        // Verify workout write permission before starting
        guard !HealthKitService().needsAuthorisationForRequiredTypes() else { return }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Avoid starting the same HK workout session multiple times for this workout.
        if SharedWorkoutStorage.hkStartedSessionId == workoutSession.id { return }
        interactor.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        interactor.startWorkout(workout: workoutSession)
        SharedWorkoutStorage.hkStartedSessionId = workoutSession.id
        #endif
    }
    
    func onScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        if newPhase == .active && oldPhase == .background {
            syncPendingSetCompletionFromWidget()
            buildView()
        }
    }
    
    func buildView() {
        // Refresh from local active session to ensure persisted edits are loaded
        guard let latest = interactor.activeSession else { return }
        workoutSession = latest
        workoutNotes = latest.notes ?? ""
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
                // Discard HK session without saving to HealthKit
                interactor.discardWorkout()
                #endif

                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End live activity with immediate dismissal for discarded workouts
                interactor.endLiveActivity(session: workoutSession, isCompleted: false, statusMessage: "Workout Discarded")
                #endif

                try interactor.deleteActiveSession()
                // Don't mark scheduled workout as complete when discarding
                UIApplication.shared.isIdleTimerDisabled = false
                SharedWorkoutStorage.clearHKStartedSessionId()

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
        
    }

    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        do {
            try interactor.updateActiveSession(workoutSession)
        } catch {
            router.showSimpleAlert(title: "Unable to Save Progress", subtitle: "We were unable to save your workout. Please try again.")
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
    
    enum WorkoutTrackerError: LocalizedError {
        case noLocalActiveWorkout
        case noActiveWorkout

        var errorDescription: String? {
            switch self {
            case .noLocalActiveWorkout:
                return "No local active workout available"
            case .noActiveWorkout:
                return "No active workout available"
            }
        }
    }

}
