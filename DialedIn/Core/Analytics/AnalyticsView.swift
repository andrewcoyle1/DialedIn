//
//  AnalyticsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct AnalyticsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct AnalyticsView<NutritionChart: View>: View {

    @Environment(\.layoutMode) private var layoutMode
    @Environment(\.scenePhase) private var scenePhase

    @State var presenter: AnalyticsPresenter
    let delegate: AnalyticsDelegate
    
    @ViewBuilder var nutritionTargetChartView: () -> NutritionChart

    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        List {
            Group {
                headerSection
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
        .navigationTitle("Analytics")
        .navigationSubtitle(presenter.selectedDate.formattedDate)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.browser)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onFirstTask {
            await presenter.onFirstTask()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await presenter.onFirstTask() }
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .onNotificationReceived(name: Constants.remoteDataSyncDidComplete) { _ in
            Task { await presenter.onFirstTask() }
        }
        .onOpenURL { url in
            presenter.handleDeepLink(url: url)
        }
        .onNotificationReceived(name: .pushNotification) { notification in
            presenter.handlePushNotificationRecieved(notification: notification)
        }
    }
    
    private var headerSection: some View {
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
            Label("Customise Analytics", systemImage: "house")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .tappableBackground()
                .anyButton {
                    presenter.onCustomiseAnalyticsPressed()
                }
        } header: {
            Text("More")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarTrailing) {
            if showDevSettingsButton {
                Button {
                    presenter.onDevSettingsPressed()
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
                
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

// MARK: - Analytics Sections (extracted for type_body_length)
private extension AnalyticsView {
    var insightsAndAnalyticsSection: some View {
        let workoutColor = Color.orange
        let expenditureColor = Color.pink
        let weightTrendColor = Color.purple
        let goalProgressColor = Color.green
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
    
    var habitsSection: some View {
        let weighInColor = Color.green
        let habitsWorkoutColor = Color.orange
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Weigh In",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.weighInCountThisWeek)",
                    subsubsubtitle: "this week",
                    themeColor: weighInColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
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
                    presenter.onWeighInConsistencyPressed(themeColor: weighInColor)
                }
                AnalyticsCard(
                    title: "Workouts",
                    subtitle: "Last 30 Days",
                    subsubtitle: "\(presenter.workoutCountThisWeek)",
                    subsubsubtitle: "this week",
                    themeColor: habitsWorkoutColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    ContributionChartView(
                        data: presenter.workoutContributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: habitsWorkoutColor,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onWorkoutConsistencyPressed(themeColor: habitsWorkoutColor)
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
    
    var nutritionSection: some View {
        let proteinColor = MacroProgressChart.proteinColor
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Macros",
                    subtitle: "Last 7 Days",
                    subsubtitle: presenter.macrosLast7Days.isEmpty ? "--" : Int(presenter.macrosAverageCalories).formatted(),
                    subsubsubtitle: "kcal",
                    themeColor: proteinColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        let chartData = presenter.macrosLast7Days.isEmpty
                            ? Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
                            : presenter.macrosLast7Days
                        return MacroStackedBarChart(data: chartData)
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onMacrosPressed(themeColor: proteinColor)
                }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "Today",
                    subsubtitle: !presenter.macrosLast7Days.isEmpty ? presenter.proteinCurrent.formatted(.number.precision(.fractionLength(1))) : "--",
                    subsubsubtitle: "g",
                    themeColor: proteinColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2),
                    chart: {
                        MacroProgressChart(
                            current: presenter.proteinCurrent,
                            target: presenter.proteinTarget,
                            maxValue: presenter.proteinMax,
                            color: proteinColor
                        )
                    }
                )
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onProteinPressed(themeColor: proteinColor)
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

    var bodyMetricsSection: some View {
        let scaleWeightColor = Color.green
        let bodyFatColor = Color.green
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Scale Weight",
                    subtitle: presenter.scaleWeightSubtitle,
                    subsubtitle: presenter.scaleWeightLatestValueText,
                    subsubsubtitle: presenter.scaleWeightUnitText,
                    themeColor: scaleWeightColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.scaleWeightSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: scaleWeightColor,
                            lineWidth: 2,
                            fillColor: scaleWeightColor,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onScaleWeightPressed(themeColor: scaleWeightColor)
                }
                AnalyticsCard(title: "Visual Body Fat", subtitle: presenter.bodyFatSubtitle, subsubtitle: presenter.bodyFatLatestValueText, subsubsubtitle: presenter.bodyFatUnitText, themeColor: bodyFatColor, chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)) {
                    SparklineChart(
                        data: presenter.bodyFatSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: bodyFatColor,
                            lineWidth: 2,
                            fillColor: bodyFatColor,
                            height: 36
                        )
                    )

                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onVisualBodyFatPressed(themeColor: bodyFatColor)
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

    var muscleGroupsSection: some View {
        let muscleGroupColor = Color.blue
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(presenter.muscleGroupCards, id: \.muscle) { item in
                    AnalyticsCard(
                        title: item.muscle.name,
                        subtitle: "Last 7 Days",
                        subsubtitle: item.totalSets.formatted(.number.precision(.fractionLength(0...1))),
                        subsubsubtitle: "sets",
                        themeColor: muscleGroupColor,
                        chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                    ) {
                        SetsBarChart(data: item.last7DaysData, color: muscleGroupColor)
                    }
                    .tappableBackground()
                    .anyButton(.press) {
                        presenter.onMuscleGroupPressed(muscle: item.muscle, themeColor: muscleGroupColor)
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

    var exercisesSection: some View {
        let exerciseColor = Color.cyan
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(presenter.exerciseCards) { item in
                    AnalyticsCard(
                        title: item.name,
                        subtitle: "Last 7 Workouts",
                        subsubtitle: item.latest1RM > 0 ? item.latest1RM.formatted(.number.precision(.fractionLength(1))) : "--",
                        subsubsubtitle: "kg",
                        themeColor: exerciseColor,
                        chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                    ) {
                        SparklineChart(
                            data: item.sparklineData,
                            configuration: SparklineConfiguration(
                                lineColor: exerciseColor,
                                lineWidth: 2,
                                fillColor: exerciseColor,
                                height: 36
                            )
                        )
                    }
                    .tappableBackground()
                    .anyButton(.press) {
                        presenter.onExercisePressed(templateId: item.templateId, name: item.name, themeColor: exerciseColor)
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

    var generalSection: some View {
        let stepsColor = Color.orange
        return Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(
                    title: "Steps",
                    subtitle: presenter.stepsSubtitle,
                    subsubtitle: presenter.stepsLatestValueText,
                    subsubsubtitle: presenter.stepsUnitText,
                    themeColor: stepsColor,
                    chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.stepsSparklineData,
                        configuration: SparklineConfiguration(
                            lineColor: stepsColor,
                            lineWidth: 2,
                            fillColor: stepsColor,
                            height: 36
                        )
                    )
                }
                .tappableBackground()
                .anyButton(.press) {
                    presenter.onStepsPressed(themeColor: stepsColor)
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("General")
        }
    }
}

extension CoreBuilder {
    
    func analyticsView(delegate: AnalyticsDelegate, router: AnyRouter) -> some View {
        AnalyticsView(
            presenter: AnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            nutritionTargetChartView: {
                self.nutritionTargetChartView()
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = AnalyticsDelegate()
    RouterView { router in
        builder.analyticsView(delegate: delegate, router: router)
    }
    
}

#Preview("w/ Notifications Test") {
    let container = DevPreview.shared.container()
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(notificationsTest: true), logger: LogManager()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = AnalyticsDelegate()
    return RouterView { router in
        builder.analyticsView(delegate: delegate, router: router)
    }
    
}
