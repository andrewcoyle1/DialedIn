import SwiftUI

struct BodyMetricsDelegate {
    
}

struct BodyMetricsView: View {
    
    @State var presenter: BodyMetricsPresenter
    let delegate: BodyMetricsDelegate
    
    var body: some View {
        List {
            Group {
                weightAndBodyFatSection
                visualMetricSection
                upperBodySection
                armsSection
                legsSection
                ratiosSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Body Metrics")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "BodyMetricsView")
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
    
    private var weightAndBodyFatSection: some View {
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
                DashboardCard(
                    title: "Visual Body Fat",
                    subtitle: presenter.bodyFatSubtitle,
                    subsubtitle: presenter.bodyFatLatestValueText,
                    subsubsubtitle: presenter.bodyFatUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
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
            Text("Weight & Body Fat")
        }
    }
    
    private var visualMetricSection: some View {
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
                DashboardCard(title: "Food Logging", subtitle: "Last 30 Days", subsubtitle: "3/7", subsubsubtitle: "this week")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Visual & Metric Overview")
        }
    }
    
    private var upperBodySection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(title: "Neck", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Shoulders", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Bust", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Chest", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Waist", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Hips", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Upper Body")
        }
    }
    
    private var armsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(title: "Left Bicep", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Bicep", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Left Forearm", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Forearm", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Left Wrist", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Wrist", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Arms")
        }
    }
    
    private var legsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(title: "Left Thigh", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Thigh", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Left Calf", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Calf", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Left Ankle", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Right Ankle", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: "in")
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Legs")
        }
    }
    
    private var ratiosSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                DashboardCard(title: "Waist to Height", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: nil)
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Waist to Hip", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: nil)
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Ratios")
        }
    }
}

extension CoreBuilder {
    
    func bodyMetricsView(router: Router, delegate: BodyMetricsDelegate) -> some View {
        BodyMetricsView(
            presenter: BodyMetricsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showBodyMetricsView(delegate: BodyMetricsDelegate) {
        router.showScreen(.sheet) { router in
            builder.bodyMetricsView(router: router, delegate: delegate)
        }
    }    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = BodyMetricsDelegate()
    
    return RouterView { router in
        builder.bodyMetricsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
