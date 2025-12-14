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
    TodaysWorkout: View, WorkoutCalendar: View, WeeksWorkouts: View, GoalListSectionView: View, TrainingProgress: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: TrainingPresenter

    @ViewBuilder var todaysWorkoutSectionView: () -> TodaysWorkout
    @ViewBuilder var workoutCalendarView: () -> WorkoutCalendar
    @ViewBuilder var thisWeeksWorkoutsView: () -> WeeksWorkouts
    @ViewBuilder var goalListSectionView: () -> GoalListSectionView
    @ViewBuilder var trainingProgressChartsView: () -> TrainingProgress

    var body: some View {
        List {
            if presenter.currentTrainingPlan != nil {
                activeProgramView
            } else {
                noProgramView
            }
            librariesSection
        }
        .navigationTitle("Training")
        .navigationSubtitle(presenter.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
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
            todaysWorkoutSectionView()
            startEmptyWorkoutButton
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
            startEmptyWorkoutButton
        }
    }
    
    private var startEmptyWorkoutButton: some View {
        Button {
            presenter.onStartEmptyWorkoutPressed()
        } label: {
            Text("Start an empty workout")
        }
    }

    private var librariesSection: some View {
        Group {
            Section {
                Button {
                    presenter.onWorkoutLibraryPressed()
                } label: {
                    Text("Workout Library")
                }
            } header: {
                Text("Workout Library")
            }
            
            Section {
                Button {
                    presenter.onExerciseLibraryPressed()
                } label: {
                    Text("Exercise Library")
                }
            } header: {
                Text("Exercise Library")
            }
            
            Section {
                Button {
                    presenter.onWorkoutHistoryPressed()
                } label: {
                    Text("Workout History")
                }
            } header: {
                Text("Workout History")
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
