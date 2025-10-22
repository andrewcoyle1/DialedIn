//
//  WorkoutCalendarViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutCalendarViewModel {
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager

    var isShowingCalendar: Bool = true
    var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    var selectedDate: Date?
    var showWorkoutMenu: Bool = false
    private(set) var workoutsForMenu: [ScheduledWorkout] = []
    var showAlert: AnyAppAlert?
    
    var workoutToStart: WorkoutTemplateModel?
    var scheduledWorkoutToStart: ScheduledWorkout?
    var selectedHistorySession: WorkoutSessionModel?
    var isShowingInspector: Bool = false
    
    var trainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    init(
        container: DependencyContainer
    ) {
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
    }
    
    func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
    
    func loadScheduledWorkouts() {
        guard let plan = trainingPlanManager.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
    }
    
    func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
    
    func handleDateTapped(_ date: Date) {
        selectedDate = date
        let workouts = workoutsForDate(date)
        
        if workouts.isEmpty {
            return
        } else if workouts.count == 1 {
            // Single workout - handle directly
            Task {
                await handleWorkoutSelection(workouts[0])
            }
        } else {
            // Multiple workouts - show menu
            workoutsForMenu = workouts
            showWorkoutMenu = true
        }
    }
    
    func handleWorkoutSelection(_ workout: ScheduledWorkout) async {
        if workout.isCompleted {
            await openCompletedSession(for: workout)
        } else {
            do {
                try await startWorkout(workout)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
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
