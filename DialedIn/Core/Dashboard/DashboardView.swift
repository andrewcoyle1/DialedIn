import SwiftUI

struct DashboardDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct DashboardView<
    WorkoutSessionRow: View,
    TodaysCard: View,
    StreakCard: View
>: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate

    @ViewBuilder var workoutSessionRow: (WorkoutSessionRowDelegate) -> WorkoutSessionRow
    @ViewBuilder var todaysWorkoutCard: (TodaysWorkoutCardDelegate) -> TodaysCard
    @ViewBuilder var workoutStreakCard: (WorkoutStreakDelegate) -> StreakCard
    
    var body: some View {
        List {
            Group {
                cardsSection
                Section { } header: {
                    Text("Workout Feed")
                }
                .listSectionMargins(.vertical, 0)
            }
            .listSectionSpacing(0)
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
    
    private var cardsSection: some View {
        Section {
            TabView {
                if let todaysWorkoutTemplate = presenter.todaysWorkoutTemplate {
                    Tab {
                        todaysWorkoutCard(
                            TodaysWorkoutCardDelegate(
                                todaysWorkoutTemplate: todaysWorkoutTemplate
                            )
                        )
                        .padding(.bottom)
                    }
                }

                Tab {
                    workoutStreakCard(WorkoutStreakDelegate())
                        .padding(.bottom)
                }

                Tab {
                    nutritionCard
                        .padding(.bottom)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 260)
            .removeListRowFormatting()
        }
        .listSectionMargins(.all, 0)
        .listSectionSeparator(.hidden)
    }

    private var nutritionCard: some View {
        NutritionCard(
            calories: presenter.nutritionTotals?.calories ?? 0,
            calorieTarget: presenter.nutritionTarget?.calories ?? 2000,
            proteinGrams: presenter.nutritionTotals?.proteinGrams ?? 0,
            proteinTarget: presenter.nutritionTarget?.proteinGrams ?? 150,
            carbGrams: presenter.nutritionTotals?.carbGrams ?? 0,
            carbTarget: presenter.nutritionTarget?.carbGrams ?? 250,
            fatGrams: presenter.nutritionTotals?.fatGrams ?? 0,
            fatTarget: presenter.nutritionTarget?.fatGrams ?? 70,
            onLogMealTapped: { presenter.onLogMealPressed() }
        )
    }
    
    @ViewBuilder
    private var workoutFeedSection: some View {
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
            }
        }
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
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate,
            workoutSessionRow: { delegate in
                self.workoutSessionRowView(
                    router: router,
                    delegate: delegate
                )
            },
            todaysWorkoutCard: { cardDelegate in
                self.todaysWorkoutCard(
                    router: router,
                    delegate: cardDelegate
                )
            },
            workoutStreakCard: { delegate in
                self.workoutStreakCardView(
                    router: router,
                    delegate: delegate
                )
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
