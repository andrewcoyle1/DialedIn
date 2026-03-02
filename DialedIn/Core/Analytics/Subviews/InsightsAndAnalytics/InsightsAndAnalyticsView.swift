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

    private var activitySection: some View {
        let workoutColor = Color.orange
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Workouts",
                    subtitle: presenter.workoutSubtitle,
                    subsubtitle: presenter.workoutLatestValueText,
                    subsubsubtitle: presenter.workoutUnitText,
                    themeColor: workoutColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SetsBarChart(
                        data: presenter.workoutSparklineData.map(\.value),
                        slotCount: 7,
                        color: workoutColor
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
            Text("Activity")
        }
        .listSectionMargins(.horizontal, 0)
        .listRowSeparator(.hidden)
    }

    private var energySection: some View {
        let expenditureColor = Color.pink
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Expenditure",
                    subtitle: presenter.expenditureSubtitle,
                    subsubtitle: presenter.expenditureLatestValueText,
                    subsubsubtitle: presenter.expenditureUnitText,
                    themeColor: expenditureColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.expenditureSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: expenditureColor,
                            lineWidth: 2,
                            fillColor: expenditureColor,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onExpenditurePressed(themeColor: expenditureColor)
                }
                AnalyticsCard(
                    title: "Energy Balance",
                    subtitle: presenter.energyBalanceSubtitle,
                    subsubtitle: presenter.energyBalanceLatestValueText,
                    subsubsubtitle: presenter.energyBalanceUnitText,
                    themeColor: nil,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    EnergyBalanceChart(
                        expenditure: presenter.energyBalanceExpenditure,
                        energyIntake: presenter.energyBalanceIntake
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onEnergyBalancePressed(themeColor: nil)
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
        let weightTrendColor = Color.purple
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Weight Trend",
                    subtitle: presenter.weightTrendSubtitle,
                    subsubtitle: presenter.weightTrendLatestValueText,
                    subsubsubtitle: presenter.weightTrendUnitText,
                    themeColor: weightTrendColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.weightTrendSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: weightTrendColor,
                            lineWidth: 2,
                            fillColor: weightTrendColor,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWeightTrendPressed(themeColor: weightTrendColor)
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
        let goalProgressColor = Color.green
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Goal Progress",
                    subtitle: "Last 7 Days",
                    subsubtitle: "14",
                    subsubsubtitle: "%",
                    themeColor: goalProgressColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(current: 14, target: 100, maxValue: 100, color: goalProgressColor)
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onGoalProgressPressed(themeColor: goalProgressColor)
                }
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
    
    func insightsAndAnalyticsView(router: AnyRouter, delegate: InsightsAndAnalyticsDelegate) -> some View {
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
    
}
