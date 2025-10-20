//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI

struct ProgramView: View {
    
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(ProgramTemplateManager.self) private var programTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(AuthManager.self) private var authManager
    
    @Binding var isShowingInspector: Bool
    @Binding var selectedWorkoutTemplate: WorkoutTemplateModel?
    @Binding var selectedExerciseTemplate: ExerciseTemplateModel?
    @Binding var selectedHistorySession: WorkoutSessionModel?
    // Sheet coordination is hoisted to TrainingView
    @Binding var activeSheet: ActiveSheet?
    @Binding var workoutToStart: WorkoutTemplateModel?
    @Binding var scheduledWorkoutToStart: ScheduledWorkout?

    @State private var isShowingCalendar: Bool = true
    enum ActiveSheet: Identifiable {
        case programPicker
        case progressDashboard
        case strengthProgress
        case workoutHeatmap
        var id: String {
            switch self {
            case .programPicker: return "programPicker"
            case .progressDashboard: return "progressDashboard"
            case .strengthProgress: return "strengthProgress"
            case .workoutHeatmap: return "workoutHeatmap"
            }
        }
    }
    @State private var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        listContents
            .showCustomAlert(alert: $showAlert)
    }
    
    private var listContents: some View {
        // Group {
        List {
            if trainingPlanManager.currentTrainingPlan != nil {
                activeProgramView
            } else {
                noProgramView
            }
        }
    }
    
    private var activeProgramView: some View {
        Group {
            programOverviewSection
            todaysWorkoutSection
            calendarSection
            weekProgressSection
            goalsSection
            chartSection
        }
    }
    
    private var programOverviewSection: some View {
        Section {
            if let plan = trainingPlanManager.currentTrainingPlan {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            if let description = plan.description {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Menu {
                            Button {
                                DispatchQueue.main.async {
                                    activeSheet = .programPicker
                                }
                            } label: {
                                Label("Manage Programs", systemImage: "list.bullet")
                            }
                            
                            Button {
                                DispatchQueue.main.async {
                                    activeSheet = .progressDashboard
                                }
                            } label: {
                                Label("View Analytics", systemImage: "chart.xyaxis.line")
                            }

                            Button {
                                DispatchQueue.main.async {
                                    activeSheet = .strengthProgress
                                }
                            } label: {
                                Label("Strength Progress", systemImage: "chart.line.uptrend.xyaxis")
                            }

                            Button {
                                DispatchQueue.main.async {
                                    activeSheet = .workoutHeatmap
                                }
                            } label: {
                                Label("Training Frequency", systemImage: "square.grid.3x3.fill.square")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    
                    // Quick stats
                    HStack(spacing: 20) {
                        StatBadge(
                            value: "\(Int(trainingPlanManager.getAdherenceRate() * 100))%",
                            label: "Adherence",
                            systemImage: "checkmark.circle.fill",
                            color: adherenceColor(trainingPlanManager.getAdherenceRate())
                        )
                        
                        if let currentWeek = trainingPlanManager.getCurrentWeek() {
                            let progress = trainingPlanManager.getWeeklyProgress(for: currentWeek.weekNumber)
                            StatBadge(
                                value: "\(progress.completedWorkouts)/\(progress.totalWorkouts)",
                                label: "This Week",
                                systemImage: "calendar",
                                color: .blue
                            )
                        }
                        
                        let upcomingCount = trainingPlanManager.getUpcomingWorkouts().count
                        StatBadge(
                            value: "\(upcomingCount)",
                            label: "Upcoming",
                            systemImage: "clock",
                            color: .orange
                        )
                    }
                    
                    // Program timeline
                    if let endDate = plan.endDate {
                        ProgressView(value: progressValue(start: plan.startDate, end: endDate)) {
                            HStack {
                                Text("Week \(currentWeekNumber(start: plan.startDate)) of \(totalWeeks(start: plan.startDate, end: endDate))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(daysRemaining(until: endDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Active Program")
        }
    }
    
    private var todaysWorkoutSection: some View {
        Group {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                Section {
                    ForEach(todaysWorkouts) { workout in
                        if workout.isCompleted {
                            WorkoutSummaryCard(
                                scheduledWorkout: workout,
                                onTap: {
                                    Task {
                                        await openCompletedSession(for: workout)
                                    }
                                }
                            )
                        } else {
                            TodaysWorkoutCard(
                                scheduledWorkout: workout,
                                onStart: {
                                    Task {
                                        do {
                                            try await startWorkout(workout)
                                        } catch {
                                            showAlert = AnyAppAlert(error: error)
                                        }
                                    }
                                }
                            )
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Today's Workout")
                    }
                }
            }
        }
    }
    
    private var calendarSection: some View {
        WorkoutCalendarView(
            workoutToStart: $workoutToStart,
            scheduledWorkoutToStart: $scheduledWorkoutToStart,
            selectedHistorySession: $selectedHistorySession,
            isShowingInspector: $isShowingInspector
        )
    }
    
    private var weekProgressSection: some View {
        Section {
            weekProgressContent
        } header: {
            Text("This Week's Workouts")
        }
    }
    
    @ViewBuilder
    private var weekProgressContent: some View {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
            ForEach(0..<7, id: \.self) { dayOffset in
                dayWorkoutRow(dayOffset: dayOffset, weekStart: weekInterval.start, calendar: calendar)
            }
        }
    }
    
    @ViewBuilder
    private func dayWorkoutRow(dayOffset: Int, weekStart: Date, calendar: Calendar) -> some View {
        let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
        let workoutsForDay = getWorkoutsForDay(day, calendar: calendar)
        
        if workoutsForDay.isEmpty {
            RestDayRow(date: day)
        } else {
            ForEach(workoutsForDay) { workout in
                if workout.isCompleted {
                    WorkoutSummaryCard(
                        scheduledWorkout: workout,
                        onTap: {
                            Task {
                                await openCompletedSession(for: workout)
                            }
                        }
                    )
                } else {
                    ScheduledWorkoutRow(scheduledWorkout: workout)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                do {
                                    try await startWorkout(workout)
                                } catch {
                                    showAlert = AnyAppAlert(error: error)
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func getWorkoutsForDay(_ day: Date, calendar: Calendar) -> [ScheduledWorkout] {
        (trainingPlanManager.currentTrainingPlan?.weeks.flatMap { $0.scheduledWorkouts } ?? [])
            .filter { workout in
                guard let scheduled = workout.scheduledDate else { return false }
                return calendar.isDate(scheduled, inSameDayAs: day)
            }
            .sorted { ($0.scheduledDate ?? .distantFuture) < ($1.scheduledDate ?? .distantFuture) }
    }

    private var goalsSection: some View {
        Group {
            if let plan = trainingPlanManager.currentTrainingPlan, !plan.goals.isEmpty {
                Section {
                    ForEach(plan.goals) { goal in
                        GoalProgressRow(goal: goal)
                    }
                } header: {
                    Text("Goals")
                }
            }
        }
    }
    
    private var chartSection: some View {
        Section {
            Button {
                DispatchQueue.main.async {
                    activeSheet = .progressDashboard
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("View Progress Analytics")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Text("Track volume, strength, and performance")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 8)
            }
            
            HistoryChart(series: TimeSeriesData.last30Days)
        } header: {
            Text("Activity")
        }
    }
    
    private var noProgramView: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("No Active Program")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Start a training program to schedule workouts and track your progress")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    DispatchQueue.main.async {
                        activeSheet = .programPicker
                    }
                } label: {
                    Label("Choose Program", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
    }
    
    // MARK: - Helper Methods
    
    private func adherenceColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.6 { return .orange }
        return .red
    }
    
    private func progressValue(start: Date, end: Date) -> Double {
        let total = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return min(max(elapsed / total, 0), 1)
    }
    
    private func currentWeekNumber(start: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: .now).weekOfYear ?? 0
        return weeks + 1
    }
    
    private func totalWeeks(start: Date, end: Date) -> Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: start, to: end).weekOfYear ?? 0
        return weeks + 1
    }
    
    private func daysRemaining(until date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        if days == 0 {
            return "Ends today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
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
        ProgramView(isShowingInspector: Binding.constant(true),
                    selectedWorkoutTemplate: Binding.constant(nil),
                    selectedExerciseTemplate: Binding.constant(nil),
                    selectedHistorySession: Binding.constant(nil),
                    activeSheet: Binding.constant(nil),
                    workoutToStart: Binding.constant(nil),
                    scheduledWorkoutToStart: Binding.constant(nil))
    }
    .previewEnvironment()
}
