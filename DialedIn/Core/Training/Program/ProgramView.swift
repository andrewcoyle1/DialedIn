//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI

struct ProgramView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.layoutMode) private var layoutMode
    @State var viewModel: ProgramViewModel
    
    var body: some View {
        List {
            if viewModel.currentTrainingPlan != nil {
                activeProgramView
            } else {
                noProgramView
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Training")
        .navigationSubtitle(viewModel.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .onFirstTask {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .sheet(isPresented: $viewModel.showAddGoalSheet) {
            if let plan = viewModel.currentTrainingPlan {
                AddGoalView(viewModel: AddGoalViewModel(interactor: CoreInteractor(container: container)), plan: plan)
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
                                // DispatchQueue.main.async {
                                    viewModel.setActiveSheet(.programPicker)
                                // }
                            } label: {
                                Label("Manage Programs", systemImage: "list.bullet")
                            }
                            
                            Button {
                                // DispatchQueue.main.async {
                                    viewModel.setActiveSheet(.progressDashboard)
                                // }
                            } label: {
                                Label("View Analytics", systemImage: "chart.xyaxis.line")
                            }

                            Button {
                                // DispatchQueue.main.async {
                                    viewModel.setActiveSheet(.strengthProgress)
                                // }
                            } label: {
                                Label("Strength Progress", systemImage: "chart.line.uptrend.xyaxis")
                            }

                            Button {
                                // DispatchQueue.main.async {
                                    viewModel.setActiveSheet(.workoutHeatmap)
                                // }
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
                                    interactor: CoreInteractor(container: container),
                                    scheduledWorkout: workout,
                                    onTap: {
                                        viewModel.openCompletedSession(for: workout)
                                    }
                                )
                            )
                            .id(workout.id)
                        } else {
                            TodaysWorkoutCardView(
                                viewModel: TodaysWorkoutCardViewModel(interactor: CoreInteractor(container: container),
                                scheduledWorkout: workout,
                                onStart: {
                                    Task {
                                        await viewModel.startWorkout(workout)
                                    }
                                })
                            )
                        }
                    }
                } header: {
                    Text("Today's Workout")
                }
            }
        }
    }
    
    private var calendarSection: some View {
        WorkoutCalendarView(
            viewModel: WorkoutCalendarViewModel(
                interactor: CoreInteractor(
                    container: container
                ), onSessionSelectionChanged: { session in
                    viewModel.selectedHistorySession = session
                },
                onWorkoutStartRequested: viewModel.handleWorkoutStartRequest
            )
        )
    }
    
    private var weekProgressSection: some View {
        Section {
            let calendar = Calendar.current
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    dayWorkoutRow(dayOffset: dayOffset, weekStart: weekInterval.start, calendar: calendar)
                }
            }
        } header: {
            Text("This Week's Workouts")
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
                            interactor: CoreInteractor(container: container),
                            scheduledWorkout: workout,
                            onTap: {
                                viewModel.openCompletedSession(for: workout)
                            }
                        )
                    )
                    .id(workout.id)
                } else {
                    ScheduledWorkoutRowView(
                        viewModel: ScheduledWorkoutRowViewModel(
                            interactor: CoreInteractor(container: container),
                            scheduledWorkout: workout
                        )
                    )
                    .contentShape(
                        Rectangle()
                    )
                    .onTapGesture {
                        Task {
                            await viewModel.startWorkout(
                                workout
                            )
                        }
                    }
                }
            }
        }
    }

    private var goalsSection: some View {
        Group {
            if let plan = viewModel.currentTrainingPlan {
                Section {
                    if !plan.goals.isEmpty {
                        ForEach(plan.goals) { goal in
                            GoalProgressRow(goal: goal)
                        }
                    } else {
                        ContentUnavailableView {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                        } description: {
                            Text("No training goals set. Tap the plus button to add one.")
                        } actions: {
                            Button {
                                if viewModel.currentTrainingPlan != nil {
                                    viewModel.showAddGoalSheet = true
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                        }

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

#Preview("No Active Program") {
    let container = DevPreview.shared.container
    // Override with empty training plan manager
    let emptyTrainingPlanManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: nil))
    container.register(TrainingPlanManager.self, service: emptyTrainingPlanManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Active Program - High Adherence") {
    let container = DevPreview.shared.container
    let highAdherenceManager = TrainingPlanManager(
        services: MockTrainingPlanServices(
            customPlan: TrainingPlan.mockHighAdherence
        )
    )
    container.register(
        TrainingPlanManager.self,
        service: highAdherenceManager
    )
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Active Program - Low Adherence") {
    let container = DevPreview.shared.container
    let lowAdherenceManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockLowAdherence))
    container.register(TrainingPlanManager.self, service: lowAdherenceManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Today's Workout - Incomplete") {
    let container = DevPreview.shared.container
    let todaysWorkoutManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithTodaysWorkout))
    container.register(TrainingPlanManager.self, service: todaysWorkoutManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Today's Workout - Completed") {
    let container = DevPreview.shared.container
    let completedWorkoutManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithCompletedTodaysWorkout))
    container.register(TrainingPlanManager.self, service: completedWorkoutManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Multiple Today's Workouts") {
    let container = DevPreview.shared.container
    let multipleWorkoutsManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithMultipleTodaysWorkouts))
    container.register(TrainingPlanManager.self, service: multipleWorkoutsManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("No Goals Set") {
    let container = DevPreview.shared.container
    let noGoalsManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockNoGoals))
    container.register(TrainingPlanManager.self, service: noGoalsManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Program Near End") {
    let container = DevPreview.shared.container
    let nearEndManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockNearEnd))
    container.register(TrainingPlanManager.self, service: nearEndManager)
    
    return NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

#Preview("Mid-Program Progress") {
    NavigationStack {
        ProgramView(viewModel: ProgramViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), onActiveSheetChanged: nil))
    }
    .previewEnvironment()
}

enum ActiveSheet: Identifiable {
    case programPicker
    case progressDashboard
    case strengthProgress
    case workoutHeatmap
    case addGoal
    
    var id: String {
        switch self {
        case .programPicker: return "programPicker"
        case .progressDashboard: return "progressDashboard"
        case .strengthProgress: return "strengthProgress"
        case .workoutHeatmap: return "workoutHeatmap"
        case .addGoal: return "addGoal"
        }
    }
    
    var eventParameters: [String: Any] {
        let sheet = self
        let params: [String: Any] = [
            "program_sheet": sheet.id
        ]
        
        return params
    }
}
