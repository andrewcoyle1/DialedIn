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
        .scrollIndicators(.hidden)
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
                DashboardCard(title: nil, subtitle: nil, subsubtitle: "No Photos", subsubsubtitle: nil) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                    .tappableBackground()
                    .anyButton(.press) {
                        
                    }
                DashboardCard(title: "Full Body", subtitle: "12 Jan 2026", subsubtitle: "1", subsubsubtitle: "metric")
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
                DashboardCard(
                    title: "Neck",
                    subtitle: presenter.neckCircumferenceSubtitle,
                    subsubtitle: presenter.neckLatestValueText,
                    subsubsubtitle: presenter.neckUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.neckSparklineData,
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
                    presenter.onNeckMeasurementPressed()
                }
                DashboardCard(
                    title: "Shoulders",
                    subtitle: presenter.shoulderCircumferenceSubtitle,
                    subsubtitle: presenter.shouldersLastEntriesLatestValueText,
                    subsubsubtitle: presenter.shouldersUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.shouldersSparklineData,
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
                    presenter.onShouldersMeasurementPressed()
                }
                DashboardCard(
                    title: "Bust",
                    subtitle: presenter.bustSubtitle,
                    subsubtitle: presenter.bustLatestValueText,
                    subsubsubtitle: presenter.bustUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.bustSparklineData,
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
                    presenter.onBustMeasurementPressed()
                }
                DashboardCard(
                    title: "Chest",
                    subtitle: presenter.chestSubtitle,
                    subsubtitle: presenter.chestLatestValueText,
                    subsubsubtitle: presenter.chestUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.chestSparklineData,
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
                    presenter.onChestMeasurementPressed()
                }
                DashboardCard(
                    title: "Waist",
                    subtitle: presenter.waistSubtitle,
                    subsubtitle: presenter.waistLatestValueText,
                    subsubsubtitle: presenter.waistUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.waistSparklineData,
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
                    presenter.onWaistMeasurementPressed()
                }
                DashboardCard(
                    title: "Hips",
                    subtitle: presenter.hipsSubtitle,
                    subsubtitle: presenter.hipsLatestValueText,
                    subsubsubtitle: presenter.hipsUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.hipsSparklineData,
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
                    presenter.onHipsMeasurementPressed()
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
                DashboardCard(
                    title: "Left Bicep",
                    subtitle: presenter.leftBicepSubtitle,
                    subsubtitle: presenter.leftBicepLatestValueText,
                    subsubsubtitle: presenter.leftBicepUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftBicepSparklineData,
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
                    presenter.onLeftBicepMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Bicep",
                    subtitle: presenter.rightBicepSubtitle,
                    subsubtitle: presenter.rightBicepLatestValueText,
                    subsubsubtitle: presenter.rightBicepUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightBicepSparklineData,
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
                    presenter.onRightBicepMeasurementPressed()
                }
                DashboardCard(
                    title: "Left Forearm",
                    subtitle: presenter.leftForearmSubtitle,
                    subsubtitle: presenter.leftForearmLatestValueText,
                    subsubsubtitle: presenter.leftForearmUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftForearmSparklineData,
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
                    presenter.onLeftForearmMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Forearm",
                    subtitle: presenter.rightForearmSubtitle,
                    subsubtitle: presenter.rightForearmLatestValueText,
                    subsubsubtitle: presenter.rightForearmUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightForearmSparklineData,
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
                    presenter.onRightForearmMeasurementPressed()
                }
                DashboardCard(
                    title: "Left Wrist",
                    subtitle: presenter.leftWristSubtitle,
                    subsubtitle: presenter.leftWristLatestValueText,
                    subsubsubtitle: presenter.leftWristUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftWristSparklineData,
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
                    presenter.onLeftWristMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Wrist",
                    subtitle: presenter.rightWristSubtitle,
                    subsubtitle: presenter.rightWristLatestValueText,
                    subsubsubtitle: presenter.rightWristUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightWristSparklineData,
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
                    presenter.onRightWristMeasurementPressed()
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
                DashboardCard(
                    title: "Left Thigh",
                    subtitle: presenter.leftThighSubtitle,
                    subsubtitle: presenter.leftThighLatestValueText,
                    subsubsubtitle: presenter.leftThighUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftThighSparklineData,
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
                    presenter.onLeftThighMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Thigh",
                    subtitle: presenter.rightThighSubtitle,
                    subsubtitle: presenter.rightThighLatestValueText,
                    subsubsubtitle: presenter.rightThighUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightThighSparklineData,
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
                    presenter.onRightThighMeasurementPressed()
                }
                DashboardCard(
                    title: "Left Calf",
                    subtitle: presenter.leftCalfSubtitle,
                    subsubtitle: presenter.leftCalfLatestValueText,
                    subsubsubtitle: presenter.leftCalfUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftCalfSparklineData,
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
                    presenter.onLeftCalfMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Calf",
                    subtitle: presenter.rightCalfSubtitle,
                    subsubtitle: presenter.rightCalfLatestValueText,
                    subsubsubtitle: presenter.rightCalfUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightCalfSparklineData,
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
                    presenter.onRightCalfMeasurementPressed()
                }
                DashboardCard(
                    title: "Left Ankle",
                    subtitle: presenter.leftAnkleSubtitle,
                    subsubtitle: presenter.leftAnkleLatestValueText,
                    subsubsubtitle: presenter.leftAnkleUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.leftAnkleSparklineData,
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
                    presenter.onLeftAnkleMeasurementPressed()
                }
                DashboardCard(
                    title: "Right Ankle",
                    subtitle: presenter.rightAnkleSubtitle,
                    subsubtitle: presenter.rightAnkleLatestValueText,
                    subsubsubtitle: presenter.rightAnkleUnitText,
                    chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                ) {
                    SparklineChart(
                        data: presenter.rightAnkleSparklineData,
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
                    presenter.onRightAnkleMeasurementPressed()
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
