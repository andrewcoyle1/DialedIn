import SwiftUI

@MainActor
protocol MetricDetailPresenter {
    associatedtype Entry: MetricEntry

    var entries: [Entry] { get }
    var timeSeries: [TimeSeries] { get }
    var configuration: MetricConfiguration { get }
    /// When non-nil, this view is used instead of the default `MetricChart` (e.g. for Energy Balance's line+bar chart).
    var customChartView: AnyView? { get }
    /// When non-nil, a contribution-style chart is shown instead of the default chart.
    var contributionChartData: [Double]? { get }
    /// Whether the entry rows offer a Delete swipe. Defaults to false: most of these screens show
    /// values derived from meals, workouts or the user profile, and their `onDeleteEntry` is a
    /// documented no-op — the swipe action was offered on every one of them regardless, so
    /// "Delete" appeared to work and silently did nothing.
    var supportsDeletion: Bool { get }
    /// The value shown in an entry row, for screens whose stored unit differs from the displayed
    /// one. Weight is stored in kilograms and body circumferences in centimetres, so a screen whose
    /// `Entry` is the stored model has to convert somewhere. Defaults to the entry's own
    /// `displayValue`.
    func displayValue(for entry: Entry) -> String

    func onAppear() async
    func onAddPressed()
    func onDismissPressed()
    func onDeleteEntry(_ entry: Entry) async
}

extension MetricDetailPresenter {
    var customChartView: AnyView? { nil }
    var contributionChartData: [Double]? { nil }
    var supportsDeletion: Bool { false }

    func displayValue(for entry: Entry) -> String {
        entry.displayValue
    }

    func onDeleteEntry(_ entry: Entry) async {
        // Default no-op for presenters that don't support deletion
    }
}

struct MetricDetailView<Presenter: MetricDetailPresenter>: View {

    @State var presenter: Presenter
    var themeColor: Color?
    /// The contribution grid's shape. Its cells are square, so these also give its aspect ratio.
    private let contributionRows: Int = 3
    private let contributionColumns: Int = 10

    init(presenter: Presenter, themeColor: Color? = nil) {
        _presenter = State(initialValue: presenter)
        self.themeColor = themeColor
    }

    var body: some View {
        let configuration = presenter.configuration
        let timeSeries = presenter.timeSeries
        let entries = presenter.entries
        let readings = MetricChartReadings(series: timeSeries, configuration: configuration, color: themeColor)

        // A Health-style screen: the chart edge to edge at the top, its background carried up behind
        // the navigation bar, and the entries in inset sections below. `ChartScreen` sets the title.
        Group {
            // Only QuickCharts' own charts can mark a row's readings, so the contribution grid and
            // the custom charts go without rows.
            if usesMetricChart, !readings.days.isEmpty {
                ChartScreen(title: configuration.title) {
                    chart(configuration: configuration, series: timeSeries)
                } accessories: {
                    MetricChartRows(readings: readings)
                } moreRows: {
                    MetricChartRows(readings: readings, showsAll: true)
                } sections: {
                    listSection(configuration: configuration, entries: entries)
                }
            } else {
                ChartScreen(title: configuration.title) {
                    chart(configuration: configuration, series: timeSeries)
                } sections: {
                    listSection(configuration: configuration, entries: entries)
                }
            }
        }
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .onFirstTask {
            await presenter.onAppear()
        }
    }
    
    /// Whether the chart is `MetricChart`, rather than the contribution grid or a custom chart.
    private var usesMetricChart: Bool {
        presenter.contributionChartData == nil && presenter.customChartView == nil
    }

    @ViewBuilder
    private func chart(configuration: MetricConfiguration, series: [TimeSeries]) -> some View {
        if let contributionData = presenter.contributionChartData {
            ContributionChartView(
                data: contributionData,
                rows: contributionRows,
                columns: contributionColumns,
                targetValue: 1.0,
                blockColor: themeColor ?? configuration.chartColor ?? .green,
                blockBackgroundColor: .background,
                rectangleWidth: .infinity,
                endDate: .now,
                showsCaptioning: false
            )
            // Not `.frame(height: 300)`. The grid draws square cells sized from the width,
            // so in a 300pt box it painted ~115pt of blocks at the top and left the rest as
            // dead space above the entry list. Ten columns of three square cells is a 10:3
            // box, whatever the width.
            .aspectRatio(
                CGFloat(contributionColumns) / CGFloat(contributionRows),
                contentMode: .fit
            )
            .padding(.vertical)
        } else if let customChart = presenter.customChartView {
            customChart
                .frame(height: 300)
                .padding(.vertical)
        } else {
            MetricChart(series: series, configuration: configuration, color: themeColor)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }

        if presenter.configuration.showsAddButton {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onAddPressed()
                } label: {
                    Image(systemName: presenter.configuration.addActionSystemImage)
                }
                .accessibilityLabel(presenter.configuration.addActionTitle)
            }
        }
    }
    
    /// The entries themselves live one push away, on All Recorded Data, as in Health: listing them
    /// all here buried everything below the chart under months of rows.
    @ViewBuilder
    private func listSection(configuration: MetricConfiguration, entries: [Presenter.Entry]) -> some View {
        if entries.isEmpty {
            emptySection(configuration: configuration)
        } else {
            Section {
                // Pushed with the sheet's own router rather than through each of the thirty-odd
                // presenters that share this view, which would each need the same route.
                RouterReader { router in
                    Button {
                        router.showScreen(.push) { _ in
                            MetricAllDataView(presenter: presenter)
                        }
                    } label: {
                        HStack {
                            Text("Show All Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    /// An empty metric screen offers the same Add action as the toolbar, so it is not a dead end.
    private func emptySection(configuration: MetricConfiguration) -> some View {
        Section {
            ContentUnavailableView {
                Label(configuration.title, systemImage: "chart.xyaxis.line")
            } description: {
                Text(configuration.emptyStateMessage)
            } actions: {
                if configuration.showsAddButton {
                    Button(configuration.addActionTitle) {
                        presenter.onAddPressed()
                    }
                }
            }
        } header: {
            Text(configuration.sectionHeader)
        }
    }
}
