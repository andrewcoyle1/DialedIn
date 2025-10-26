//
//  DevSettingsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulUtilities

protocol DevSettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    var activeSession: WorkoutSessionModel? { get }
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func getCurrentWeek() -> TrainingWeek?
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel]
    func updatePlan(_ plan: TrainingPlan) async throws
    func trackEvent(event: LoggableEvent)
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
    func clearAllTrainingPlanLocalData() throws
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws
    func logOut()
    func signOut() throws
}

extension CoreInteractor: DevSettingsInteractor { }

@Observable
@MainActor
class DevSettingsViewModel {
    private let interactor: DevSettingsInteractor
    
    private(set) var isReseeding = false
    private(set) var reseedingMessage = ""
    private(set) var fetchedSession: WorkoutSessionModel?
    private(set) var isFetchingSession = false
    private(set) var fetchError: String?

    var testSessionId = ""

    init(
        interactor: DevSettingsInteractor
    ) {
        self.interactor = interactor
    }
    
    func authParams() -> [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func userParams() -> [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func deviceParams() -> [(key: String, value: Any)] {
        SwiftfulUtilities.Utilities.eventParameters.asAlphabeticalArray
    }
    
    func getLocalExercises() -> [ExerciseTemplateModel] {
        (try? interactor.getAllLocalExerciseTemplates()) ?? []
    }
    
    func getLocalWorkoutTemplates() -> [WorkoutTemplateModel] {
        (try? interactor.getAllLocalWorkoutTemplates()) ?? []
    }
    
    func getLocalTrainingPlan() -> TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    func getCurrentTrainingPlanWeek() -> TrainingWeek? {
        interactor.getCurrentWeek()
    }
    
    func getTodaysWorkouts() -> [ScheduledWorkout] {
        interactor.getTodaysWorkouts()
    }
    
    func getActiveSession() -> WorkoutSessionModel? {
        interactor.activeSession
    }
    
    func getActiveLocalWorkoutSession() -> WorkoutSessionModel? {
        try? interactor.getActiveLocalWorkoutSession()
    }
    
    func getRecentWorkoutSessions() -> [WorkoutSessionModel] {
        (try? interactor.getAllLocalWorkoutSessions()) ?? []
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
        
        guard var plan = interactor.currentTrainingPlan else {
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
        try? await interactor.updatePlan(plan)
        
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
            let session = try await interactor.getWorkoutSession(id: testSessionId)
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
        interactor.trackEvent(event: Event.forceSignOutStart)
        Task {
            guard let userId = interactor.currentUser?.userId else {
                // No user, just sign out
                signOutAuth()
                return
            }
            
            // 1. Stop all listeners FIRST to prevent permission errors
            interactor.trackEvent(event: Event.clearTrainingPlansStart)
            do {
                // Stop TrainingPlanManager listener
                try
                interactor.clearAllTrainingPlanLocalData()
                interactor.trackEvent(event: Event.clearTrainingPlansSuccess)
            } catch {
                interactor.trackEvent(event: Event.clearTrainingPlansFail(error: error))
            }
            
            // 2. Clear ALL local data
            // Clear workout sessions
            interactor.trackEvent(event: Event.clearWorkoutSessionsStart)
            do {
                try interactor.deleteAllLocalWorkoutSessionsForAuthor(authorId: userId)
                interactor.trackEvent(event: Event.clearWorkoutSessionsSuccess)
            } catch {
                interactor.trackEvent(event: Event.clearWorkoutSessionsFail(error: error))
            }
            
            // Clear user data and stop UserManager listener
            interactor.logOut()
            
            // 3. Sign out (account remains intact in Firebase)
            signOutAuth()
            
            // UI will reset to onboarding automatically when auth state changes
        }
    }
    
    func signOutAuth() {
        interactor.trackEvent(event: Event.authSignOutStart)
        do {
            try interactor.signOut()
            interactor.trackEvent(event: Event.authSignOutSuccess)
        } catch {
            interactor.trackEvent(event: Event.authSignOutFail(error: error))
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
