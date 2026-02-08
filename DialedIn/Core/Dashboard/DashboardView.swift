//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct DashboardView<NutritionChart: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: DashboardPresenter

    @ViewBuilder var nutritionTargetChartView: () -> NutritionChart

    var body: some View {
        List {
            Group {
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            nutritionTargetSection
                            contributionChartSection
                        }
                        .padding(.horizontal)
                    }
                    .scrollTargetLayout()
                    .scrollTargetBehavior(.paging)
                    .removeListRowFormatting()
                }
                .listSectionMargins(.top, 0)
                carouselSection
                insightsAndAnalyticsSection
                habitsSection
                nutritionSection
                bodyMetricsSection
                muscleGroupsSection
                exercisesSection
                generalSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
            moreSection
        }
        .navigationTitle("Dashboard")
        .navigationSubtitle(presenter.selectedDate.formattedDate)
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .onFirstTask {
            await presenter.onFirstTask()
        }
        .onOpenURL { url in
            presenter.handleDeepLink(url: url)
        }
    }
    
    private var inspectorContent: some View {
        Group {
            Text("Select an item")
                .foregroundStyle(.secondary)
                .padding()
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }
    
    private var carouselSection: some View {
        Section {
            
        } header: {
            
        }
    }
    
    private var insightsAndAnalyticsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Workouts",
                    subtitle: presenter.workoutSubtitle,
                    subsubtitle: presenter.workoutLatestValueText,
                    subsubsubtitle: presenter.workoutUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SetsBarChart(
                        data: presenter.workoutSparklineData.map(\.value),
                        slotCount: 7,
                        color: .orange
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWorkoutsPressed()
                }
                
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
                            lineColor: .pink,
                            lineWidth: 2,
                            fillColor: .pink,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onExpenditurePressed()
                }

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
                            lineColor: .purple,
                            lineWidth: 2,
                            fillColor: .purple,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWeightTrendPressed()
                }
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
                .anyButton(.press) {
                    presenter.onGoalProgressPressed()
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
            HStack(alignment: .firstTextBaseline) {
                Text("Insights & Analytics")
             Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton {
                        presenter.onSeeAllInsightsPressed()
                    }
            }
        }
    }
    
    private var habitsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Weigh In",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.weighInCountThisWeek)",
                    subsubsubtitle: "this week",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.weighInContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: .green,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onScaleWeightPressed()
                }
                DashboardCard(
                    title: "Workouts",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.workoutCountThisWeek)",
                    subsubsubtitle: "this week",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.workoutContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: .orange,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
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
            HStack(alignment: .firstTextBaseline) {
                Text("Habits")
             Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton {
                        presenter.onSeeAllHabitsPressed()
                    }
            }
        }
    }
    
    private var nutritionSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Macros",
                    subtitle: "Last 7 Days",
                    subsubtitle: "700",
                    subsubsubtitle: "kcal",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        let chartData = presenter.macrosLast7Days.isEmpty
                            ? Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
                            : presenter.macrosLast7Days
                        return MacroStackedBarChart(data: chartData)
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onMacrosPressed()
                }
                DashboardCard(
                    title: "Protein",
                    subtitle: "Today",
                    subsubtitle: "48.3",
                    subsubsubtitle: "g",
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(current: 48.3, target: 150, maxValue: 200, color: MacroProgressChart.proteinColor)
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onProteinPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()

        } header: {
            HStack {
                Text("Nutrition")
                Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton(.press) {
                        presenter.onSeeAllNutritionAnalyticsPressed()
                    }
            }

        }
    }

    private var bodyMetricsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Scale Weight",
                    subtitle: presenter.scaleWeightSubtitle,
                    subsubtitle: presenter.scaleWeightLatestValueText,
                    subsubsubtitle: presenter.scaleWeightUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.scaleWeightSparklineData,
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
                    presenter.onScaleWeightPressed()
                }
                DashboardCard(title: "Visual Body Fat", subtitle: presenter.bodyFatSubtitle, subsubtitle: presenter.bodyFatLatestValueText, subsubsubtitle: presenter.bodyFatUnitText, chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)) {
                    SparklineChart(
                        data: presenter.bodyFatSparklineData,
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
                    presenter.onVisualBodyFatPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Body Metrics")
                Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton(.press) {
                        presenter.onSeeAllBodyMetricsPressed()
                    }
            }
        }
    }

    private var muscleGroupsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(presenter.muscleGroupCards, id: \.muscle) { item in
                    DashboardCard(
                        title: item.muscle.name,
                        subtitle: "Last 7 Days",
                        subsubtitle: item.totalSets.formatted(.number.precision(.fractionLength(0...1))),
                        subsubsubtitle: "sets",
                        chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                    ) {
                        SetsBarChart(data: item.last7DaysData, color: .blue)
                    }
                    .tappableBackground()
                    .anyButton(.press) {
                        presenter.onMuscleGroupPressed(muscle: item.muscle)
                    }
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Muscle Groups")
                Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton(.press) {
                        presenter.onSeeAllMuscleGroupsPressed()
                    }
            }
        }
    }

    private var exercisesSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(presenter.exerciseCards) { item in
                    DashboardCard(
                        title: item.name,
                        subtitle: "Last 7 Workouts",
                        subsubtitle: item.latest1RM > 0 ? item.latest1RM.formatted(.number.precision(.fractionLength(1))) : "--",
                        subsubsubtitle: "kg",
                        chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                    ) {
                        SparklineChart(
                            data: item.sparklineData,
                            configuration: SparklineConfiguration(
                                lineColor: .cyan,
                                lineWidth: 2,
                                fillColor: .cyan,
                                height: 36
                            )
                        )
                    }
                    .tappableBackground()
                    .anyButton(.press) {
                        presenter.onExercisePressed(templateId: item.templateId, name: item.name)
                    }
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Exercises")
                Spacer()
                Text("See All")
                    .font(.caption)
                    .underline()
                    .anyButton(.press) {
                        presenter.onSeeAllExercisesPressed()
                    }
            }
        }
    }

    private var generalSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(
                    title: "Steps",
                    subtitle: presenter.stepsSubtitle,
                    subsubtitle: presenter.stepsLatestValueText,
                    subsubsubtitle: presenter.stepsUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.stepsSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: .orange,
                            lineWidth: 2,
                            fillColor: .orange,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onStepsPressed()
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }

    private var nutritionTargetSection: some View {
        nutritionTargetChartView()
            .frame(height: 300)
            .frame(width: 420)
    }
    
    private var contributionChartSection: some View {
        ContributionChartView(
            data: presenter.contributionChartData,
            rows: 7,
            columns: 16,
            targetValue: 1.0,
            blockColor: .accent,
            endDate: presenter.chartEndDate
        )
        .frame(height: 300)
        .frame(width: 420)
    }
    
    private var moreSection: some View {
        Section {
            Label("Customise Dashboard", systemImage: "house")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .tappableBackground()
                .anyButton {
                    presenter.onCustomiseDashboardPressed()
                }
        } header: {
            Text("More")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
            .badge(3)
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

extension CoreBuilder {
    
    func dashboardView(router: AnyRouter) -> some View {
        DashboardView(
            presenter: DashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: {
                self.nutritionTargetChartView()
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.dashboardView(router: router)
    }
    .previewEnvironment()
}

#Preview("w/ Notifications Test") {
    let container = DevPreview.shared.container()
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(notificationsTest: true), logger: LogManager()))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.dashboardView(router: router)
    }
    .previewEnvironment()
}
