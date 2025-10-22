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
    
    var isShowingInspector: Bool = false
    private(set) var selectedWorkoutTemplate: WorkoutTemplateModel?
    private(set) var selectedExerciseTemplate: ExerciseTemplateModel?
    var selectedHistorySession: WorkoutSessionModel?
    var activeSheet: ActiveSheet?
    var workoutToStart: WorkoutTemplateModel?
    var scheduledWorkoutToStart: ScheduledWorkout?
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
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
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
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = scheduledWorkout
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }

    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) async {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                selectedHistorySession = session
                isShowingInspector = true
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
