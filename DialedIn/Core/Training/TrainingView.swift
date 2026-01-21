//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import SwiftfulRouting

struct TrainingView<
    TodaysWorkout: View, WorkoutCalendar: View, WeeksWorkouts: View, GoalListSectionView: View, TrainingProgress: View, CalendarHeaderView: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: TrainingPresenter

    @ViewBuilder var todaysWorkoutSectionView: () -> TodaysWorkout
    @ViewBuilder var workoutCalendarView: () -> WorkoutCalendar
    @ViewBuilder var thisWeeksWorkoutsView: () -> WeeksWorkouts
    @ViewBuilder var goalListSectionView: () -> GoalListSectionView
    @ViewBuilder var trainingProgressChartsView: () -> TrainingProgress
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate) -> CalendarHeaderView

    var body: some View {
        VStack {
            calendarHeader(
                CalendarHeaderDelegate(
                    onDatePressed: { date in
                        presenter.onDatePressed(date: date)
                    },
                    getForDate: { date in
                        presenter.getLoggedWorkoutCountForDate(date, calendar: presenter.calendar)
                    }
                )
            )
            List {
                if presenter.currentTrainingPlan != nil {
                    activeProgramView
                } else {
                    noProgramView
                }
                moreSection
            }
            .refreshable {
                await presenter.refreshData()
            }
        }
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onFirstTask {
            await presenter.loadData()
        }
    }
    
    private var activeProgramView: some View {
        Group {
            todaysWorkoutSectionView()
            programOverviewSection
            workoutCalendarView()
            thisWeeksWorkoutsView()
            goalListSectionView()
            trainingProgressChartsView()
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
        todaysWorkoutSectionView()
    }
        
    private var noProgramView: some View {
        Group {
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
                        presenter.onChooseProgramPressed()
                    } label: {
                        Label("Choose Program", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
    }
    
    private var moreSection: some View {
        Group {
            Section {
                CustomListCellView(
                    imageName: nil,
                    title: "Workout Library",
                    subtitle: nil
                )
                .anyButton {
                    presenter.onWorkoutLibraryPressed()
                }
                .removeListRowFormatting()
            
                CustomListCellView(
                    imageName: nil,
                    title: "Exercise Library",
                    subtitle: nil
                )
                .anyButton {
                    presenter.onExerciseLibraryPressed()
                }
                .removeListRowFormatting()

                CustomListCellView(
                    imageName: nil,
                    title: "Workout History",
                    subtitle: nil
                )
                .anyButton {
                    presenter.onWorkoutHistoryPressed()
                }
                .removeListRowFormatting()

                CustomListCellView(
                    imageName: nil,
                    title: "Gym Profiles",
                    subtitle: nil
                )
                .anyButton {
                    presenter.onGymProfilesPressed()
                }
                .removeListRowFormatting()

            } header: {
                Text("More")
            }
        }
    }
            
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddPressed()
            } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

extension CoreBuilder {
    func trainingView(router: AnyRouter) -> some View {
        TrainingView(
            presenter: TrainingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            todaysWorkoutSectionView: {
                self.todaysWorkoutSectionView(router: router)
            },
            workoutCalendarView: {
                self.workoutCalendarView(router: router)
            },
            thisWeeksWorkoutsView: {
                self.thisWeeksWorkoutsView(router: router)
            },
            goalListSectionView: {
                self.goalListSectionView(router: router)
            },
            trainingProgressChartsView: {
                self.trainingProgressChartsView(router: router)
            },
            calendarHeader: { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}

#Preview("No Training Plan") {
    let container = DevPreview.shared.container
    container.register(TrainingPlanManager.self, service: TrainingPlanManager(services: MockTrainingPlanServices(delay: 0, showError: false, plans: [])))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}
