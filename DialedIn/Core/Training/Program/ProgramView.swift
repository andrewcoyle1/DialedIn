//
//  ProgramView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI
import CustomRouting

struct ProgramView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: ProgramPresenter

    let delegate: ProgramDelegate

    @ViewBuilder var workoutSummaryCardView: (WorkoutSummaryCardDelegate) -> AnyView
    @ViewBuilder var todaysWorkoutCardView: (TodaysWorkoutCardDelegate) -> AnyView
    @ViewBuilder var workoutCalendarView: (WorkoutCalendarDelegate) -> AnyView
    @ViewBuilder var scheduledWorkoutRowView: (ScheduledWorkoutRowDelegate) -> AnyView

    var body: some View {
        List {
            if presenter.currentTrainingPlan != nil {
                activeProgramView
            } else {
                noProgramView
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Training")
        .navigationSubtitle(presenter.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .onFirstTask {
            await presenter.loadData()
        }
        .refreshable {
            await presenter.refreshData()
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
            if let plan = presenter.currentTrainingPlan {
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
                                presenter.onProgramManagementPressed()
                            } label: {
                                Label("Manage Programs", systemImage: "list.bullet")
                            }
                            
                            Button {
                                presenter.onProgessDashboardPressed()
                            } label: {
                                Label("View Analytics", systemImage: "chart.xyaxis.line")
                            }

                            Button {
                                presenter.onStrengthProgressPressed()
                            } label: {
                                Label("Strength Progress", systemImage: "chart.line.uptrend.xyaxis")
                            }

                            Button {
                                presenter.onWorkoutHeatmapPressed()
                            } label: {
                                Label("Training Frequency", systemImage: "square.grid.3x3.fill.square")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    
                    // Quick stats
                    HStack(spacing: 20) {
                        StatCard(
                            value: "\(Int(presenter.adherenceRate*100))%",
                            label: "Adherence",
                            icon: "checkmark.circle.fill",
                            color: presenter.adherenceColor(presenter.adherenceRate)
                        )
                        
                        if let currentWeek = presenter.currentWeek {
                            let progress = presenter.getWeeklyProgress(weekNumber: currentWeek.weekNumber)
                            StatCard(
                                value: "\(progress.completedWorkouts)/\(progress.totalWorkouts)",
                                label: "This Week",
                                icon: "calendar",
                                color: .blue
                            )
                        }
                        
                        let upcomingCount = presenter.upcomingWorkouts.count
                        StatCard(
                            value: "\(upcomingCount)",
                            label: "Upcoming",
                            icon: "clock",
                            color: .orange
                        )
                    }
                    
                    // Program timeline
                    if let endDate = plan.endDate {
                        ProgressView(value: presenter.progressValue(start: plan.startDate, end: endDate)) {
                            HStack {
                                Text("Week \(presenter.currentWeekNumber(start: plan.startDate)) of \(presenter.totalWeeks(start: plan.startDate, end: endDate))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(presenter.daysRemaining(until: endDate))
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
            let todaysWorkouts = presenter.todaysWorkouts
            if !todaysWorkouts.isEmpty {
                Section {
                    ForEach(todaysWorkouts) { workout in
                        if workout.isCompleted {
                            workoutSummaryCardView(
                                WorkoutSummaryCardDelegate(
                                    scheduledWorkout: workout,
                                    onTap: {
                                        presenter.openCompletedSession(
                                            for: workout
                                        )
                                    }
                                )
                            )
                            .id(workout.id)
                        } else {
                            todaysWorkoutCardView(
                                TodaysWorkoutCardDelegate(
                                    scheduledWorkout: workout,
                                    onStart: {
                                        Task {
                                            await presenter.startWorkout(workout)
                                        }
                                    }
                                )
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
        workoutCalendarView(
            WorkoutCalendarDelegate(
                onSessionSelectionChanged: { session in
                    presenter.selectedHistorySession = session
                    presenter
                        .handleSessionSelectionChanged(
                            session
                        )
                },
                onWorkoutStartRequested: presenter.handleWorkoutStartRequest
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
        let workoutsForDay = presenter.getWorkoutsForDay(day, calendar: calendar)
        
        if workoutsForDay.isEmpty {
            RestDayRow(date: day)
        } else {
            ForEach(workoutsForDay) { workout in
                if workout.isCompleted {
                    workoutSummaryCardView(
                        WorkoutSummaryCardDelegate(
                            scheduledWorkout: workout, onTap: {
                                presenter.openCompletedSession(for: workout)
                                
                            }
                        )
                    )
                    .id(workout.id)
                } else {
                    scheduledWorkoutRowView(ScheduledWorkoutRowDelegate(scheduledWorkout: workout))
                    .contentShape(
                        Rectangle()
                    )
                    .onTapGesture {
                        Task {
                            await presenter.startWorkout(
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
            if let plan = presenter.currentTrainingPlan {
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
                                if presenter.currentTrainingPlan != nil {
                                    presenter.onAddGoalPressed()
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
                    presenter.activeSheet = .progressDashboard
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
                        presenter.activeSheet = .programPicker
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
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in
                    
                }
            )
        )
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
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Active Program - Low Adherence") {
    let container = DevPreview.shared.container
    let lowAdherenceManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockLowAdherence))
    container.register(TrainingPlanManager.self, service: lowAdherenceManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Today's Workout - Incomplete") {
    let container = DevPreview.shared.container
    let todaysWorkoutManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithTodaysWorkout))
    container.register(TrainingPlanManager.self, service: todaysWorkoutManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Today's Workout - Completed") {
    let container = DevPreview.shared.container
    let completedWorkoutManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithCompletedTodaysWorkout))
    container.register(TrainingPlanManager.self, service: completedWorkoutManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Multiple Today's Workouts") {
    let container = DevPreview.shared.container
    let multipleWorkoutsManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockWithMultipleTodaysWorkouts))
    container.register(TrainingPlanManager.self, service: multipleWorkoutsManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("No Goals Set") {
    let container = DevPreview.shared.container
    let noGoalsManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockNoGoals))
    container.register(TrainingPlanManager.self, service: noGoalsManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in
                    
                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Program Near End") {
    let container = DevPreview.shared.container
    let nearEndManager = TrainingPlanManager(services: MockTrainingPlanServices(customPlan: TrainingPlan.mockNearEnd))
    container.register(TrainingPlanManager.self, service: nearEndManager)
    let builder = CoreBuilder(container: container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in

                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Mid-Program Progress") {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    return RouterView { router in
        builder.programView(
            router: router,
            delegate: ProgramDelegate(
                onSessionSelectionChangeded: { _ in
                    
                }
            )
        )
    }
    .previewEnvironment()
}
