import SwiftUI

struct DashboardDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct DashboardView<WorkoutSessionRow: View>: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    @ViewBuilder var workoutSessionRow: (WorkoutSessionRowDelegate) -> WorkoutSessionRow
    
    var body: some View {
        List {
            Section {
                TabView {
                    if let todaysWorkoutTemplate = presenter.todaysWorkoutTemplate {
                        Tab {
                            todaysWorkoutCard(todaysWorkoutTemplate)
                        }
                    }

                    Tab {
                        streakCard
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 240)
            }
            .removeListRowFormatting()
            .listSectionMargins(.all, 0)
            .listSectionSeparator(.hidden)
            workoutFeedSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Dashboard")
        .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.browser)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .toolbar { toolbarContent }
        .task {
            await presenter.loadNotifications()
        }
    }
        
    private func todaysWorkoutCard(_ todaysWorkoutTemplate: WorkoutTemplateModel) -> some View {
        VStack(alignment: .leading) {
            Text("Today's Workout")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading)
            VStack(alignment: .leading, spacing: 12) {
                if presenter.isTodayRestDay {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text("Rest Day")
                                .font(.title3.bold())
                            Text("Recovery is part of the process.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                } else if presenter.isTodayCompleted {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading) {
                            Text(todaysWorkoutTemplate.name)
                                .font(.title3.bold())
                            Text("Completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                } else {
                    Button {
                        presenter.onTodaysWorkoutPressed()
                    } label: {
                        VStack(alignment: .leading) {
                            HStack(spacing: -10) {
                                ForEach(todaysWorkoutTemplate.exercises.prefix(5)) { exercise in
                                    exerciseCircle(exercise: exercise.exercise)
                                }
                            }
                            .frame(maxHeight: .infinity)
                            Divider()
                            HStack(spacing: 12) {
                                Image(systemName: "dumbbell.fill")
                                    .font(.title2)
                                    .foregroundStyle(.accent)
                                VStack(alignment: .leading) {
                                    Text(todaysWorkoutTemplate.name)
                                        .font(.title3.bold())
                                        .foregroundStyle(.primary)
                                    Text("\(todaysWorkoutTemplate.exercises.count) exercise\(todaysWorkoutTemplate.exercises.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .frame(height: 200)
            .background(colorScheme.backgroundPrimary)
            .cornerRadius(24)
        }
        .padding(.horizontal)
        .background(colorScheme.backgroundSecondary)
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func exerciseCircle(exercise: ExerciseModel) -> some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .secondarySystemBackground))

            ImageLoaderView(
                urlString: exercise.imageURL ?? "SplashScreen",
                resizingMode: .fit,
                clipShape: AnyShape(Circle())
            )
        }
        .frame(width: 100, height: 100)
        .overlay(Circle().stroke(Color(uiColor: .systemBackground), lineWidth: 2))
    }

    private var streakCard: some View {
        VStack(alignment: .leading) {
            Text("Workout Streak")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading)
            VStack(alignment: .leading, spacing: 16) {
                streakHeader
                weeklyDotsRow
                Divider()
                streakStats
            }
            .padding()
            .frame(height: 200)
            .background(colorScheme.backgroundPrimary)
            .cornerRadius(24)
        }
        .padding()
    }

    private var streakHeader: some View {
        HStack(alignment: .center) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(streakAccentColor)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(presenter.workoutStreakCount)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(streakAccentColor)
                Text(presenter.workoutStreakCount == 1 ? "day" : "days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            streakBadge
        }
    }

    @ViewBuilder
    private var streakBadge: some View {
        if presenter.isStreakAtRisk {
            Text("At Risk")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.yellow.opacity(0.15))
                .foregroundStyle(Color.yellow)
                .clipShape(Capsule())
        } else if presenter.isStreakActive {
            Text("Active")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.15))
                .foregroundStyle(Color.orange)
                .clipShape(Capsule())
        }
    }

    private var streakAccentColor: Color {
        if presenter.isStreakAtRisk {
            return .yellow
        } else if presenter.isStreakActive {
            return .orange
        }
        return .secondary
    }

    private var weeklyDotsRow: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdayIndex = calendar.component(.weekday, from: today) - 1
        let startOfWeek = calendar.date(byAdding: .day, value: -weekdayIndex, to: today) ?? today
        let workoutDays = presenter.workoutDaysThisWeek
        let labels = ["S", "M", "T", "W", "T", "F", "S"]

        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let day = calendar.date(byAdding: .day, value: index, to: startOfWeek) ?? startOfWeek
                let hasWorkout = workoutDays.contains(day)
                let isToday = calendar.isDateInToday(day)
                let isFuture = day > today

                VStack(spacing: 6) {
                    Text(labels[index])
                        .font(.caption2)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(isToday ? .primary : .secondary)
                    ZStack {
                        Circle()
                            .foregroundStyle(hasWorkout ? Color.orange : Color(.systemFill))
                            .opacity(hasWorkout ? 1.0 : isFuture ? 0.2 : 0.45)
                        if isToday && !hasWorkout {
                            Circle()
                                .strokeBorder(.primary.opacity(0.35), lineWidth: 1.5)
                        }
                    }
                    .frame(width: 10, height: 10)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var streakStats: some View {
        HStack {
            StatItem(header: "Best streak", value: "\(presenter.longestStreak) days")
            Spacer()
            StatItem(alignment: .trailing, header: "Total workouts", value: "\(presenter.totalWorkouts)")
        }
    }
    
    @ViewBuilder
    private var workoutFeedSection: some View {
//        Section {
            if presenter.feedSessions.isEmpty {
                ContentUnavailableView(
                    "No Workout History",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Log a workout or follow some friends to see their sessions.")
                )
            } else {
                ForEach(presenter.feedSessions) { session in
                    Section {
                        if let author = presenter.author(for: session) {
                            let rowDelegate = WorkoutSessionRowDelegate(session: session, author: author)
                            workoutSessionRow(rowDelegate)
                                .removeListRowFormatting()
                        }
                    }
//                    .removeListRowFormatting()
                }
            }
//        } header: {
//            Text("Feed")
//        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        #if DEV || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
            .badge(presenter.activityNotifications.filter({ !$0.isRead }).count)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            let avatarSize: CGFloat = 44

            Button {
                presenter.onProfilePressed()
            } label: {
                ZStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                    if let urlString = presenter.userImageUrl {
                        ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                            .frame(width: avatarSize, height: avatarSize)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = DashboardDelegate()
    
    return RouterView { router in
        builder.dashboardView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func dashboardView(router: AnyRouter, delegate: DashboardDelegate) -> some View {
        DashboardView(
            presenter: DashboardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            workoutSessionRow: { delegate in
                self.workoutSessionRowView(router: router, delegate: delegate)
            }
        )
    }
    
}

extension CoreRouter {
    
    func showDashboardView(delegate: DashboardDelegate) {
        router.showScreen(.push) { router in
            builder.dashboardView(router: router, delegate: delegate)
        }
    }
    
}
