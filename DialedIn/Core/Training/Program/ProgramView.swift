//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI

struct ProgramView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProgramViewModel
    
    var body: some View {
        List {
            if viewModel.currentTrainingPlan != nil {
                activeProgramView
            } else {
                noProgramView
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
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
            if let plan = viewModel.currentTrainingPlan {
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
                                    viewModel.activeSheet = .programPicker
                                }
                            } label: {
                                Label("Manage Programs", systemImage: "list.bullet")
                            }
                            
                            Button {
                                DispatchQueue.main.async {
                                    viewModel.activeSheet = .progressDashboard
                                }
                            } label: {
                                Label("View Analytics", systemImage: "chart.xyaxis.line")
                            }

                            Button {
                                DispatchQueue.main.async {
                                    viewModel.activeSheet = .strengthProgress
                                }
                            } label: {
                                Label("Strength Progress", systemImage: "chart.line.uptrend.xyaxis")
                            }

                            Button {
                                DispatchQueue.main.async {
                                    viewModel.activeSheet = .workoutHeatmap
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
                            value: "\(Int(viewModel.adherenceRate*100))%",
                            label: "Adherence",
                            systemImage: "checkmark.circle.fill",
                            color: viewModel.adherenceColor(viewModel.adherenceRate)
                        )
                        
                        if let currentWeek = viewModel.currentWeek {
                            let progress = viewModel.getWeeklyProgress(weekNumber: currentWeek.weekNumber)
                            StatBadge(
                                value: "\(progress.completedWorkouts)/\(progress.totalWorkouts)",
                                label: "This Week",
                                systemImage: "calendar",
                                color: .blue
                            )
                        }
                        
                        let upcomingCount = viewModel.upcomingWorkouts.count
                        StatBadge(
                            value: "\(upcomingCount)",
                            label: "Upcoming",
                            systemImage: "clock",
                            color: .orange
                        )
                    }
                    
                    // Program timeline
                    if let endDate = plan.endDate {
                        ProgressView(value: viewModel.progressValue(start: plan.startDate, end: endDate)) {
                            HStack {
                                Text("Week \(viewModel.currentWeekNumber(start: plan.startDate)) of \(viewModel.totalWeeks(start: plan.startDate, end: endDate))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(viewModel.daysRemaining(until: endDate))
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
            let todaysWorkouts = viewModel.todaysWorkouts
            if !todaysWorkouts.isEmpty {
                Section {
                    ForEach(todaysWorkouts) { workout in
                        if workout.isCompleted {
                            WorkoutSummaryCardView(
                                viewModel: WorkoutSummaryCardViewModel(
                                    container: container,
                                    scheduledWorkout: workout,
                                    onTap: {
                                        Task {
                                            await viewModel.openCompletedSession(for: workout)
                                        }
                                    }
                                )
                            )
                        } else {
                            TodaysWorkoutCardView(
                                viewModel: TodaysWorkoutCardViewModel(container: container,
                                scheduledWorkout: workout,
                                onStart: {
                                    Task {
                                        do {
                                            try await viewModel.startWorkout(workout)
                                        } catch {
                                            viewModel.showAlert = AnyAppAlert(error: error)
                                        }
                                    }
                                })
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
            viewModel: WorkoutCalendarViewModel(container: container))
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
        let workoutsForDay = viewModel.getWorkoutsForDay(day, calendar: calendar)
        
        if workoutsForDay.isEmpty {
            RestDayRow(date: day)
        } else {
            ForEach(workoutsForDay) { workout in
                if workout.isCompleted {
                    WorkoutSummaryCardView(
                        viewModel: WorkoutSummaryCardViewModel(
                            container: container,
                            scheduledWorkout: workout,
                            onTap: {
                                Task {
                                    await viewModel.openCompletedSession(for: workout)
                                }
                            }
                        )
                    )
                } else {
                    ScheduledWorkoutRowView(viewModel: ScheduledWorkoutRowViewModel(scheduledWorkout: workout))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                do {
                                    try await viewModel.startWorkout(workout)
                                } catch {
                                    viewModel.showAlert = AnyAppAlert(error: error)
                                }
                            }
                        }
                }
            }
        }
    }

    private var goalsSection: some View {
        Group {
            if let plan = viewModel.currentTrainingPlan, !plan.goals.isEmpty {
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
                    viewModel.activeSheet = .progressDashboard
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
                        viewModel.activeSheet = .programPicker
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
}

#Preview {
    List {
        ProgramView(viewModel: ProgramViewModel(container: DevPreview.shared.container))
    }
    .previewEnvironment()
}

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
