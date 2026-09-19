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

/// Gutter between the analytics header cards, and between a card and the screen edge.
private let headerCardSpacing: CGFloat = 16

struct AnalyticsView<NutritionChart: View>: View {

    @Environment(\.layoutMode) private var layoutMode
    @Environment(\.scenePhase) private var scenePhase

    @State var presenter: AnalyticsPresenter
    let delegate: AnalyticsDelegate
    let profileButtonTransition: String = "profile_button_transition"
    @ViewBuilder var nutritionTargetChartView: () -> NutritionChart

    @Namespace private var namespace
    
    var body: some View {
        List {
            Group {
                headerSection
                // Which of these appear is the Customise Analytics screen's business. The header and
                // the More list below are not hideable: one is the summary, the other is how you
                // reach everything that has been hidden.
                if presenter.isVisible(.insightsAndAnalytics) { insightsAndAnalyticsSection }
                if presenter.isVisible(.habits) { habitsSection }
                if presenter.isVisible(.nutrition) { nutritionSection }
                if presenter.isVisible(.bodyMetrics) { bodyMetricsSection }
                if presenter.isVisible(.muscleGroups) { muscleGroupsSection }
                if presenter.isVisible(.exercises) { exercisesSection }
                generalSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
            moreSection
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
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
    }
    
    private var headerSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: headerCardSpacing) {
                    nutritionTargetSection
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, headerCardSpacing, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .removeListRowFormatting()
        }
        .listSectionMargins(.top, 0)

    }
    
    // A `carouselSection` was rendered here as `Section { } header: { }` — an empty section with an
    // empty header, which draws as a stray gap under the header cards. Removed; the header cards
    // above it already carry the carousel this was presumably meant to hold.

    /// Header cards are sized from the scroll container rather than a fixed width, so they
    /// fit every device. A fixed 420pt was wider than the screen on all iPhones (iPhone 17
    /// is 402pt across) and clipped the trailing edge. Two cards share the width in
    /// split view, where there is room for both.
    @ViewBuilder
    private func headerCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(height: 300)
            .containerRelativeFrame(
                .horizontal,
                count: layoutMode == .splitView ? 2 : 1,
                spacing: headerCardSpacing
            )
    }

    private var nutritionTargetSection: some View {
        headerCard {
            nutritionTargetChartView()
        }
    }
    
    private var moreSection: some View {
        Section {
            ForEach(presenter.hiddenSections) { section in
                moreRow(title: section.title, systemImage: section.systemImage) {
                    presenter.onHiddenSectionPressed(section)
                }
            }

            // "house" here was copied from the Dashboard tab and said nothing about what the row
            // does.
            moreRow(title: "Customise Analytics", systemImage: "slider.horizontal.3") {
                presenter.onCustomiseAnalyticsPressed()
            }
        } header: {
            Text("More")
        }
    }

    private func moreRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tappableBackground()
            .anyButton(.highlight, action: action)
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
            ProfileButton(
                action: {
                    presenter.onProfilePressed(transitionId: profileButtonTransition, namespace: namespace)
                },
                imageUrl: presenter.userImageUrl
            )
            .matchedTransitionSource(id: profileButtonTransition, in: namespace)
        }
    }
}

// MARK: - Analytics Sections (extracted for type_body_length)
//
// Every section is the same three pieces: an `AnalyticsSectionHeader`, an `AnalyticsCardGrid`, and
// cards built from the shared card components in `AnalyticsSection.swift`. Sections whose contents
// are data-driven fall back to an `AnalyticsEmptyCard` so a visible header is never followed by a
// blank grid.
private extension AnalyticsView {

    var insightsAndAnalyticsSection: some View {
        let workoutColor = Color.orange
        let expenditureColor = Color.pink
        let weightTrendColor = Color.purple
        let goalProgressColor = Color.green
        return Section {
            AnalyticsCardGrid {
                AnalyticsCard(
                    title: "Workouts",
                    subtitle: presenter.workoutSubtitle,
                    subsubtitle: presenter.workoutLatestValueText,
                    subsubsubtitle: presenter.workoutUnitText,
                    themeColor: workoutColor,
                    chartConfiguration: .compact
                ) {
                    SetsBarChart(
                        data: presenter.workoutSparklineData.map(\.value),
                        slotCount: 7,
                        color: workoutColor
                    )
                }
                .analyticsCardButton {
                    presenter.onWorkoutsPressed(themeColor: workoutColor)
                }

                SparklineAnalyticsCard(
                    title: "Expenditure",
                    subtitle: presenter.expenditureSubtitle,
                    value: presenter.expenditureLatestValueText,
                    unit: presenter.expenditureUnitText,
                    themeColor: expenditureColor,
                    data: presenter.expenditureSparklineData,
                    action: { presenter.onExpenditurePressed(themeColor: expenditureColor) }
                )

                SparklineAnalyticsCard(
                    title: "Weight Trend",
                    subtitle: presenter.weightTrendSubtitle,
                    value: presenter.weightTrendLatestValueText,
                    unit: presenter.weightTrendUnitText,
                    themeColor: weightTrendColor,
                    data: presenter.weightTrendSparklineData,
                    action: { presenter.onWeightTrendPressed(themeColor: weightTrendColor) }
                )

                // Was hardcoded to "14%" over "Last 7 Days" — a placeholder that showed the same
                // number to every user, including users with no goal at all.
                AnalyticsCard(
                    title: "Goal Progress",
                    subtitle: presenter.goalProgressSubtitle,
                    subsubtitle: presenter.goalProgressLatestValueText,
                    subsubsubtitle: presenter.goalProgressUnitText,
                    themeColor: goalProgressColor,
                    chartConfiguration: .compact
                ) {
                    MacroProgressChart(
                        current: presenter.goalProgressPercent,
                        target: 100,
                        maxValue: 100,
                        color: goalProgressColor
                    )
                }
                .analyticsCardButton {
                    presenter.onGoalProgressPressed(themeColor: goalProgressColor)
                }

                AnalyticsCard(
                    title: "Energy Balance",
                    subtitle: presenter.energyBalanceSubtitle,
                    subsubtitle: presenter.energyBalanceLatestValueText,
                    subsubsubtitle: presenter.energyBalanceUnitText,
                    themeColor: nil,
                    chartConfiguration: .compact
                ) {
                    EnergyBalanceChart(
                        expenditure: presenter.energyBalanceExpenditure,
                        energyIntake: presenter.energyBalanceIntake
                    )
                }
                .analyticsCardButton {
                    presenter.onEnergyBalancePressed(themeColor: nil)
                }
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Insights & Analytics",
                onSeeAllPressed: { presenter.onSeeAllInsightsPressed() }
            )
        }
    }

    var habitsSection: some View {
        Section {
            AnalyticsCardGrid {
                ConsistencyAnalyticsCard(
                    title: "Weigh In",
                    value: "\(presenter.weighInCountThisWeek)",
                    themeColor: .green,
                    data: presenter.weighInContributionData,
                    action: { presenter.onWeighInConsistencyPressed(themeColor: .green) }
                )
                ConsistencyAnalyticsCard(
                    title: "Workouts",
                    value: "\(presenter.workoutCountThisWeek)",
                    themeColor: .orange,
                    data: presenter.workoutContributionData,
                    action: { presenter.onWorkoutConsistencyPressed(themeColor: .orange) }
                )
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Habits",
                onSeeAllPressed: { presenter.onSeeAllHabitsPressed() }
            )
        }
    }

    var nutritionSection: some View {
        let proteinColor = MacroProgressChart.proteinColor
        return Section {
            AnalyticsCardGrid {
                AnalyticsCard(
                    title: "Macros",
                    subtitle: presenter.macrosLast7Days.isEmpty ? "No Data" : "Last 7 Days",
                    subsubtitle: presenter.macrosLast7Days.isEmpty ? "--" : Int(presenter.macrosAverageCalories).formatted(),
                    subsubsubtitle: "kcal",
                    themeColor: proteinColor,
                    chartConfiguration: .compact,
                    chart: {
                        let chartData = presenter.macrosLast7Days.isEmpty
                            ? Array(repeating: DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0), count: 7)
                            : presenter.macrosLast7Days
                        return MacroStackedBarChart(data: chartData)
                    }
                )
                .analyticsCardButton {
                    presenter.onMacrosPressed(themeColor: proteinColor)
                }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: presenter.macrosLast7Days.isEmpty ? "No Data" : "Today",
                    subsubtitle: presenter.macrosLast7Days.isEmpty ? "--" : presenter.proteinCurrent.formatted(.number.precision(.fractionLength(1))),
                    subsubsubtitle: "g",
                    themeColor: proteinColor,
                    chartConfiguration: .compact,
                    chart: {
                        MacroProgressChart(
                            current: presenter.proteinCurrent,
                            target: presenter.proteinTarget,
                            maxValue: presenter.proteinMax,
                            color: proteinColor
                        )
                    }
                )
                .analyticsCardButton {
                    presenter.onProteinPressed(themeColor: proteinColor)
                }
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Nutrition",
                onSeeAllPressed: { presenter.onSeeAllNutritionAnalyticsPressed() }
            )
        }
    }

    var bodyMetricsSection: some View {
        let scaleWeightColor = Color.green
        let bodyFatColor = Color.teal
        return Section {
            AnalyticsCardGrid {
                SparklineAnalyticsCard(
                    title: "Scale Weight",
                    subtitle: presenter.scaleWeightSubtitle,
                    value: presenter.scaleWeightLatestValueText,
                    unit: presenter.scaleWeightUnitText,
                    themeColor: scaleWeightColor,
                    data: presenter.scaleWeightSparklineData,
                    action: { presenter.onScaleWeightPressed(themeColor: scaleWeightColor) }
                )
                SparklineAnalyticsCard(
                    title: "Visual Body Fat",
                    subtitle: presenter.bodyFatSubtitle,
                    value: presenter.bodyFatLatestValueText,
                    unit: presenter.bodyFatUnitText,
                    themeColor: bodyFatColor,
                    data: presenter.bodyFatSparklineData,
                    action: { presenter.onVisualBodyFatPressed(themeColor: bodyFatColor) }
                )
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Body Metrics",
                onSeeAllPressed: { presenter.onSeeAllBodyMetricsPressed() }
            )
        }
    }

    var muscleGroupsSection: some View {
        let muscleGroupColor = Color.blue
        return Section {
            AnalyticsCardGrid {
                if presenter.muscleGroupCards.isEmpty {
                    AnalyticsEmptyCard(message: "Log a workout to see your weekly sets by muscle group.")
                } else {
                    ForEach(presenter.muscleGroupCards, id: \.muscle) { item in
                        AnalyticsCard(
                            title: item.muscle.name,
                            subtitle: "Last 7 Days",
                            subsubtitle: item.totalSets.formatted(.number.precision(.fractionLength(0...1))),
                            subsubsubtitle: "sets",
                            themeColor: muscleGroupColor,
                            chartConfiguration: .compact
                        ) {
                            SetsBarChart(data: item.last7DaysData, color: muscleGroupColor)
                        }
                        .analyticsCardButton {
                            presenter.onMuscleGroupPressed(muscle: item.muscle, themeColor: muscleGroupColor)
                        }
                    }
                }
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Muscle Groups",
                onSeeAllPressed: { presenter.onSeeAllMuscleGroupsPressed() }
            )
        }
    }

    var exercisesSection: some View {
        let exerciseColor = Color.cyan
        return Section {
            AnalyticsCardGrid {
                if presenter.exerciseCards.isEmpty {
                    AnalyticsEmptyCard(message: "Log a workout to track your estimated one-rep max.")
                } else {
                    ForEach(presenter.exerciseCards) { item in
                        SparklineAnalyticsCard(
                            title: item.name,
                            subtitle: "Last 7 Workouts",
                            value: item.latest1RM > 0 ? item.latest1RM.formatted(.number.precision(.fractionLength(1))) : "--",
                            unit: item.unitText,
                            themeColor: exerciseColor,
                            data: item.sparklineData,
                            action: {
                                presenter.onExercisePressed(
                                    templateId: item.templateId,
                                    name: item.name,
                                    themeColor: exerciseColor
                                )
                            }
                        )
                    }
                }
            }
        } header: {
            AnalyticsSectionHeader(
                title: "Exercises",
                onSeeAllPressed: { presenter.onSeeAllExercisesPressed() }
            )
        }
    }

    var generalSection: some View {
        let stepsColor = Color.orange
        return Section {
            AnalyticsCardGrid {
                SparklineAnalyticsCard(
                    title: "Steps",
                    subtitle: presenter.stepsSubtitle,
                    value: presenter.stepsLatestValueText,
                    unit: presenter.stepsUnitText,
                    themeColor: stepsColor,
                    data: presenter.stepsSparklineData,
                    action: { presenter.onStepsPressed(themeColor: stepsColor) }
                )
            }
        } header: {
            AnalyticsSectionHeader(title: "General")
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
