//
//  DevSettingsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class DevSettingsViewModel {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager
    private let logManager: LogManager
    
    private(set) var isReseeding = false
    private(set) var reseedingMessage = ""
    private(set) var fetchedSession: WorkoutSessionModel?
    private(set) var isFetchingSession = false
    private(set) var fetchError: String?

    var testSessionId = ""

    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func authParams() -> [(key: String, value: Any)] {
        authManager.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func userParams() -> [(key: String, value: Any)] {
        userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func deviceParams() -> [(key: String, value: Any)] {
        SwiftfulUtilities.Utilities.eventParameters.asAlphabeticalArray
    }
    
    func getLocalExercises() -> [ExerciseTemplateModel] {
        (try? exerciseTemplateManager.getAllLocalExerciseTemplates()) ?? []
    }
    
    func getLocalWorkoutTemplates() -> [WorkoutTemplateModel] {
        (try? workoutTemplateManager.getAllLocalWorkoutTemplates()) ?? []
    }
    
    func getLocalTrainingPlan() -> TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    func getCurrentTrainingPlanWeek() -> TrainingWeek? {
        trainingPlanManager.getCurrentWeek()
    }
    
    func getTodaysWorkouts() -> [ScheduledWorkout] {
        trainingPlanManager.getTodaysWorkouts()
    }
    
    func getActiveSession() -> WorkoutSessionModel? {
        workoutSessionManager.activeSession
    }
    
    func getActiveLocalWorkoutSession() -> WorkoutSessionModel? {
        try? workoutSessionManager.getActiveLocalWorkoutSession()
    }
    
    func getRecentWorkoutSessions() -> [WorkoutSessionModel] {
        (try? workoutSessionManager.getAllLocalWorkoutSessions()) ?? []
    }
    
    func dismiss(_ dismiss: ()) {
        // Perform any cleanup before dismissing if needed
        dismiss
    }
    
    func resetExerciseSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting exercises..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetWorkoutSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting workouts..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetAllSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting all seeding..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetTodaysWorkouts() async {
        isReseeding = true
        reseedingMessage = "Resetting today's workouts..."
        
        guard var plan = trainingPlanManager.currentTrainingPlan else {
            reseedingMessage = "No active plan"
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isReseeding = false
            reseedingMessage = ""
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find and reset today's workouts
        for (weekIndex, week) in plan.weeks.enumerated() {
            for (workoutIndex, workout) in week.scheduledWorkouts.enumerated() {
                if let scheduledDate = workout.scheduledDate,
                   calendar.isDate(scheduledDate, inSameDayAs: today) {
                    // Reset to incomplete
                    let resetWorkout = ScheduledWorkout(
                        id: workout.id,
                        workoutTemplateId: workout.workoutTemplateId,
                        dayOfWeek: workout.dayOfWeek,
                        scheduledDate: workout.scheduledDate,
                        completedSessionId: nil,
                        isCompleted: false,
                        notes: workout.notes
                    )
                    plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = resetWorkout
                }
            }
        }
        
        // Save updated plan
        try? await trainingPlanManager.updatePlan(plan)
        
        reseedingMessage = "Reset complete!"
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func fetchSessionFromFirebase() async {
        isFetchingSession = true
        fetchError = nil
        fetchedSession = nil
        
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: testSessionId)
            await MainActor.run {
                fetchedSession = session
                isFetchingSession = false
            }
        } catch {
            await MainActor.run {
                fetchError = error.localizedDescription
                isFetchingSession = false
            }
        }
    }
    
    func onForceFreshAnonUser() {
        logManager.trackEvent(event: Event.forceSignOutStart)
        Task {
            guard let userId = userManager.currentUser?.userId else {
                // No user, just sign out
                signOutAuth()
                return
            }
            
            // 1. Stop all listeners FIRST to prevent permission errors
            logManager.trackEvent(event: Event.clearTrainingPlansStart)
            do {
                // Stop TrainingPlanManager listener
                try
                trainingPlanManager.clearAllLocalData()
                logManager.trackEvent(event: Event.clearTrainingPlansSuccess)
            } catch {
                logManager.trackEvent(event: Event.clearTrainingPlansFail(error: error))
            }
            
            // 2. Clear ALL local data
            // Clear workout sessions
            logManager.trackEvent(event: Event.clearWorkoutSessionsStart)
            do {
                try workoutSessionManager.deleteAllLocalWorkoutSessionsForAuthor(authorId: userId)
                logManager.trackEvent(event: Event.clearWorkoutSessionsSuccess)
            } catch {
                logManager.trackEvent(event: Event.clearWorkoutSessionsFail(error: error))
            }
            
            // Clear user data and stop UserManager listener
            userManager.signOut()
            
            // 3. Sign out (account remains intact in Firebase)
            signOutAuth()
            
            // UI will reset to onboarding automatically when auth state changes
        }
    }
    
    func signOutAuth() {
        logManager.trackEvent(event: Event.authSignOutStart)
        do {
            try authManager.signOut()
            logManager.trackEvent(event: Event.authSignOutSuccess)
        } catch {
            logManager.trackEvent(event: Event.authSignOutFail(error: error))
        }
    }
    
    enum Event: LoggableEvent {
        case forceSignOutStart
        case forceSignOutSuccess
        case clearTrainingPlansStart
        case clearTrainingPlansSuccess
        case clearTrainingPlansFail(error: Error)
        case clearWorkoutSessionsStart
        case clearWorkoutSessionsSuccess
        case clearWorkoutSessionsFail(error: Error)
        case forceSignOutFail(error: Error)
        case authSignOutStart
        case authSignOutSuccess
        case authSignOutFail(error: Error)

        var eventName: String {
            switch self {
            case .forceSignOutStart:            return "DevSettingsView_ForceSignOut_Start"
            case .forceSignOutSuccess:          return "DevSettingsView_ForceSignOut_Success"
            case .clearTrainingPlansStart:      return "DevSettingsView_ClearTrainingPlans_Start"
            case .clearTrainingPlansSuccess:    return "DevSettingsView_ClearTrainingPlans_Success"
            case .clearTrainingPlansFail:       return "DevSettingsView_ClearTrainingPlans_Fail"
            case .clearWorkoutSessionsStart:    return "DevSettingsView_ClearWorkoutSessions_Start"
            case .clearWorkoutSessionsSuccess:  return "DevSettingsView_ClearWorkoutSessions_Success"
            case .clearWorkoutSessionsFail:     return "DevSettingsView_ClearWorkoutSessions_Fail"
            case .forceSignOutFail:             return "DevSettingsView_ForceSignOut_Fail"
            case .authSignOutStart:             return "DevSettingsView_AuthSignOut_Start"
            case .authSignOutSuccess:           return "DevSettingsView_AuthSignOut_Success"
            case .authSignOutFail:              return "DevSettingsView_AuthSignOut_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .forceSignOutFail(error: let error), .authSignOutFail(error: let error), .clearTrainingPlansFail(error: let error), .clearWorkoutSessionsFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .forceSignOutFail, .authSignOutFail, .clearTrainingPlansFail, .clearWorkoutSessionsFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
