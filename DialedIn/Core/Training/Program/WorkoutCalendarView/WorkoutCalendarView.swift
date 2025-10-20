//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct WorkoutCalendarView: View {
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    
    @Binding var workoutToStart: WorkoutTemplateModel?
    @Binding var scheduledWorkoutToStart: ScheduledWorkout?
    @Binding var selectedHistorySession: WorkoutSessionModel?
    @Binding var isShowingInspector: Bool
    
    @State private var isShowingCalendar: Bool = true
    @State private var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    @State private var scheduledWorkouts: [ScheduledWorkout] = []
    @State private var selectedDate: Date?
    @State private var showWorkoutMenu: Bool = false
    @State private var workoutsForMenu: [ScheduledWorkout] = []
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        Section(isExpanded: $isShowingCalendar) {
            EnhancedScheduleView(
                scheduledWorkouts: scheduledWorkouts,
                onDateSelected: { date in
                    selectedDate = date
                    collapsedSubtitle = "Next: \(date.formatted(.dateTime.day().month()))"
                },
                onDateTapped: { date in
                    handleDateTapped(date)
                }
            )
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Plan")
                if !isShowingCalendar {
                    Text(collapsedSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingCalendar ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onCalendarToggled()
            }
            .animation(.easeInOut, value: isShowingCalendar)
        }
        .confirmationDialog(
            selectedDate?.formatted(date: .long, time: .omitted) ?? "Select Workout",
            isPresented: $showWorkoutMenu,
            titleVisibility: .visible
        ) {
            ForEach(workoutsForMenu) { workout in
                Button {
                    Task {
                        await handleWorkoutSelection(workout)
                    }
                } label: {
                    if let name = workout.workoutName {
                        Text("\(name) \(workout.isCompleted ? "✓" : "")")
                    } else {
                        Text("Workout \(workout.isCompleted ? "✓" : "")")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .showCustomAlert(alert: $showAlert)
        .onAppear {
            loadScheduledWorkouts()
        }
        .onChange(of: trainingPlanManager.currentTrainingPlan) { _, _ in
            loadScheduledWorkouts()
        }
    }
    
    private func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
    
    private func loadScheduledWorkouts() {
        guard let plan = trainingPlanManager.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
    }
    
    private func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
    
    private func handleDateTapped(_ date: Date) {
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
    
    private func handleWorkoutSelection(_ workout: ScheduledWorkout) async {
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
    
    private func startWorkout(_ scheduledWorkout: ScheduledWorkout) async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = scheduledWorkout
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }
    
    private func openCompletedSession(for scheduledWorkout: ScheduledWorkout) async {
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

#Preview {
    List {
        WorkoutCalendarView(
            workoutToStart: .constant(nil),
            scheduledWorkoutToStart: .constant(nil),
            selectedHistorySession: .constant(nil),
            isShowingInspector: .constant(false)
        )
    }
    .previewEnvironment()
}
