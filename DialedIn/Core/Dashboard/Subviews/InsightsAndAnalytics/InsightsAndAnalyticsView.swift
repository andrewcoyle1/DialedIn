import SwiftUI

struct InsightsAndAnalyticsDelegate {
    
}

struct InsightsAndAnalyticsView: View {
    
    @State var presenter: InsightsAndAnalyticsPresenter
    let delegate: InsightsAndAnalyticsDelegate
    
    var body: some View {
        List {
            activitySection
            energySection
            bodySection
            goalsSection
        }
        .navigationTitle("Insights & Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "InsightsAndAnalyticsView")
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

    private var activitySection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Workouts",
                    subtitle: presenter.workoutSubtitle,
                    subsubtitle: presenter.workoutLatestValueText,
                    subsubsubtitle: presenter.workoutUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.workoutSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: .green,
                            lineWidth: 2,
                            fillColor: .green,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWorkoutsPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Activity")
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }

    private var energySection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Expenditure",
                    subtitle: presenter.expenditureSubtitle,
                    subsubtitle: presenter.expenditureLatestValueText,
                    subsubsubtitle: presenter.expenditureUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.expenditureSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: .green,
                            lineWidth: 2,
                            fillColor: .green,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onExpenditurePressed()
                }
                DashboardCard(
                    title: "Energy Balance",
                    subtitle: presenter.energyBalanceSubtitle,
                    subsubtitle: presenter.energyBalanceLatestValueText,
                    subsubsubtitle: presenter.energyBalanceUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    EnergyBalanceChart(
                        expenditure: presenter.energyBalanceExpenditure,
                        energyIntake: presenter.energyBalanceIntake
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onEnergyBalancePressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Energy")
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }

    private var bodySection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Weight Trend",
                    subtitle: presenter.weightTrendSubtitle,
                    subsubtitle: presenter.weightTrendLatestValueText,
                    subsubsubtitle: presenter.weightTrendUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.weightTrendSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: .green,
                            lineWidth: 2,
                            fillColor: .green,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWeightTrendPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Body")
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }

    private var goalsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Goal Progress",
                    subtitle: "Last 7 Days",
                    subsubtitle: "14",
                    subsubsubtitle: "%",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(current: 14, target: 100, maxValue: 100, color: .green)
                    }
                )
                .tappableBackground()
                .anyButton(.press) { }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Goals")
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }
}

extension CoreBuilder {
    
    func insightsAndAnalyticsView(router: Router, delegate: InsightsAndAnalyticsDelegate) -> some View {
        InsightsAndAnalyticsView(
            presenter: InsightsAndAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showInsightsAndAnalyticsView(delegate: InsightsAndAnalyticsDelegate) {
        router.showScreen(.sheet) { router in
            builder.insightsAndAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = InsightsAndAnalyticsDelegate()
    
    return RouterView { router in
        builder.insightsAndAnalyticsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
