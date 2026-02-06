//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct DashboardView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: DashboardPresenter

    @ViewBuilder var nutritionTargetChartView: () -> AnyView

    @Namespace private var namespace

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
        .toolbarTitleDisplayMode(.inlineLarge)
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
                DashboardCard(title: "Workouts", subtitle: "Last 7 Workouts", subsubtitle: "12", subsubsubtitle: "sets")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Expenditure", subtitle: "Last 7 Days", subsubtitle: "2993", subsubsubtitle: "kcal")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
//                DashboardCard(title: "Weight Trend", subtitle: "Last 7 Days", subsubtitle: "83.2", subsubsubtitle: "kg")
//                DashboardCard(title: "Energy Balance", subtitle: "Last 7 Days", subsubtitle: "1696", subsubsubtitle: "kcal deficit")
//                DashboardCard(title: "Goal Progress", subtitle: "Last 4 Days", subsubtitle: "7", subsubsubtitle: "%")
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
                DashboardCard(title: "Weigh In", subtitle: "Last 30 Days", subsubtitle: "3/7", subsubsubtitle: "this week")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Workouts", subtitle: "Last 30 Days", subsubtitle: "2", subsubsubtitle: "this week")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
//                DashboardCard(title: "Food Logging", subtitle: "Last 30 Days", subsubtitle: "3/7", subsubsubtitle: "this week")
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
                DashboardCard(title: "Macros", subtitle: "Last 7 Days", subsubtitle: "700", subsubsubtitle: "kcal")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()

        } header: {
            Text("Nutrition")
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
                            lineColor: .accent,
                            lineWidth: 2,
                            fillColor: .accent,
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
                            lineColor: .accent,
                            lineWidth: 2,
                            fillColor: .accent,
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
                DashboardCard(title: "Upper Back", subtitle: "Last 7 Days", subsubtitle: "6", subsubsubtitle: "sets")
                    .tappableBackground()
                    .anyButton(.press) {

                    }
                DashboardCard(title: "Rear Delts", subtitle: "Last 7 Entries", subsubtitle: "6", subsubsubtitle: "sets")
                    .tappableBackground()
                    .anyButton(.press) {

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
                DashboardCard(title: "Neutral Grip Machine Fly", subtitle: "Last 7 Workouts", subsubtitle: "116", subsubsubtitle: "kg")
                    .tappableBackground()
                    .anyButton(.press) {

                    }
                DashboardCard(title: "Low Pulley Cable Rope Overhead Triceps Extension", subtitle: "Last 7 Entries", subsubtitle: "80", subsubsubtitle: "kg")
                    .tappableBackground()
                    .anyButton(.press) {

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
                DashboardCard(title: "Steps", subtitle: "Last 7 Entries", subsubtitle: "342", subsubsubtitle: "steps")
                    .tappableBackground()
                    .anyButton(.press) {

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
            .frame(width: 400)

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
        .frame(height: 220)
        .frame(width: 400)
    }
    
    private var moreSection: some View {
        Section {
            CustomListCellView(sfSymbolName: "house", title: "Customise Dashboard")
                .removeListRowFormatting()
        } header: {
            Text("More")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

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
                    .any()
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
