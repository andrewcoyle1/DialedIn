//
//  ProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramViewModel {
    
    private let authManager: AuthManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    private let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    private let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?
    
    private(set) var selectedWorkoutTemplate: WorkoutTemplateModel?
    private(set) var selectedExerciseTemplate: ExerciseTemplateModel?
    var selectedHistorySession: WorkoutSessionModel?
    var activeSheet: ActiveSheet?
    private(set) var isShowingCalendar: Bool = true
    private(set) var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    var showAlert: AnyAppAlert?
    
    var currentTrainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    var adherenceRate: Double {
        trainingPlanManager.getAdherenceRate()
    }
    
    var currentWeek: TrainingWeek? {
        trainingPlanManager.getCurrentWeek()
    }
    
    var upcomingWorkouts: [ScheduledWorkout] {
        trainingPlanManager.getUpcomingWorkouts()
    }
    
    var todaysWorkouts: [ScheduledWorkout] {
        trainingPlanManager.getTodaysWorkouts()
    }
    
    var navigationSubtitle: String {
        if let plan = trainingPlanManager.currentTrainingPlan {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = trainingPlanManager.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return ""
    }
    init(
        container: DependencyContainer,
        onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil,
        onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)? = nil
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.onSessionSelectionChanged = onSessionSelectionChanged
        self.onWorkoutStartRequested = onWorkoutStartRequested
    }
    
    func getWeeklyProgress(weekNumber: Int) -> WeekProgress {
        trainingPlanManager.getWeeklyProgress(for: weekNumber)
    }
    
    func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        (trainingPlanManager.currentTrainingPlan?.weeks.flatMap { $0.scheduledWorkouts } ?? [])
            .filter { workout in
                guard let scheduled = workout.scheduledDate else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }
    
    func adherenceColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.6 { return .orange }
        return .red
    }
    
    func progressValue(start: Date, end: Date) -> Double {
        let total = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return min(max(elapsed / total, 0), 1)
    }
    
    func currentWeekNumber(start: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: .now).weekOfYear ?? 0
        return weeks + 1
    }
    
    func totalWeeks(start: Date, end: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: end).weekOfYear ?? 0
        return weeks + 1
    }
    
    func daysRemaining(until date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        if days == 0 {
            return "Ends today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
        }
    }
    
    func handleWorkoutStartRequest(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        onWorkoutStartRequested?(template, scheduledWorkout)
    }
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Notify parent to show WorkoutStartView
        onWorkoutStartRequested?(template, scheduledWorkout)
    }

    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) async {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                selectedHistorySession = session
                onSessionSelectionChanged?(session)
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    // MARK: - Data Loading
    
    private func ensureUserIdIsSet() {
        // Ensure userId is set in trainingPlanManager before syncing
        if let userId = try? authManager.getAuthId() {
            trainingPlanManager.setUserId(userId)
        }
    }
    
    func loadData() async {
        ensureUserIdIsSet()
        
        do {
            try await trainingPlanManager.syncFromRemote()
        } catch {
            // Silently fail on initial load - we'll have local data if available
            print("Failed to sync training plan: \(error.localizedDescription)")
        }
    }
    
    func refreshData() async {
        ensureUserIdIsSet()
        
        do {
            try await trainingPlanManager.syncFromRemote()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
