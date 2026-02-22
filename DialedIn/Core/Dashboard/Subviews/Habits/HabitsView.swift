import SwiftUI

struct HabitsDelegate {
    
}

struct HabitsView: View {
    
    @State var presenter: HabitsPresenter
    let delegate: HabitsDelegate
    
    var body: some View {
        List {
            Group {
                generalSection
                trainingSection
                nutritionSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Habits")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .onFirstTask {
            await presenter.onFirstTask()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) {
                    presenter.onDismissPressed()
                }
            }
        }
    }
    
    private var generalSection: some View {
        let weighInColor = Color.green
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Weigh In",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.weighInCountThisWeek)",
                    subsubsubtitle: "this week",
                    themeColor: weighInColor,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.weighInContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: weighInColor,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWeighInPressed(themeColor: weighInColor)
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }
    
    private var trainingSection: some View {
        let workoutColor = Color.orange
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Workouts",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.workoutCountThisWeek)",
                    subsubsubtitle: "this week",
                    themeColor: workoutColor,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.workoutContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: workoutColor,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWorkoutsPressed(themeColor: workoutColor)
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Training")
        }
    }
    
    private var nutritionSection: some View {
        let foodLoggingColor = Color.orange
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Food Logging",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.foodLoggingCountThisWeek)/7",
                    subsubsubtitle: "this week",
                    themeColor: foodLoggingColor,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.foodLoggingContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: foodLoggingColor,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onFoodLoggingPressed(themeColor: foodLoggingColor)
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Nutrition")
        }
    }
}

extension CoreBuilder {
    
    func habitsView(router: AnyRouter, delegate: HabitsDelegate) -> some View {
        HabitsView(
            presenter: HabitsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showHabitsView(delegate: HabitsDelegate) {
        router.showScreen(.sheet) { router in
            builder.habitsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = HabitsDelegate()
    
    return RouterView { router in
        builder.habitsView(router: router, delegate: delegate)
    }
    
}
