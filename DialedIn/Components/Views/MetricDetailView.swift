import SwiftUI

@MainActor
protocol MetricDetailPresenter {
    associatedtype Entry: MetricEntry

    var entries: [Entry] { get }
    var timeSeries: [TimeSeriesData.TimeSeries] { get }
    var configuration: MetricConfiguration { get }
    /// When non-nil, this view is used instead of the default NewHistoryChart (e.g. for Energy Balance's line+bar chart).
    var customChartView: AnyView? { get }
    /// When non-nil, a contribution-style chart is shown instead of the default chart.
    var contributionChartData: [Double]? { get }

    func onAppear() async
    func onAddPressed()
    func onDismissPressed()
    func onDeleteEntry(_ entry: Entry) async
}

extension MetricDetailPresenter {
    var customChartView: AnyView? { nil }
    var contributionChartData: [Double]? { nil }

    func onDeleteEntry(_ entry: Entry) async {
        // Default no-op for presenters that don't support deletion
    }
}

struct MetricDetailView<Presenter: MetricDetailPresenter>: View {

    struct VisibleMetrics {
        var startDate: Date?
        var endDate: Date?
        var averageValues: [Double?]
        var delta: [Double?]
        
        static var empty: VisibleMetrics {
            VisibleMetrics(
                startDate: nil,
                endDate: nil,
                averageValues: [],
                delta: []
            )
        }
    }

    @State var presenter: Presenter
    @State private var page: Int = 1
    @State private var visibleMetrics: VisibleMetrics = .empty

    var body: some View {
        let configuration = presenter.configuration
        let timeSeries = presenter.timeSeries
        let entries = presenter.entries
        let pageSize = configuration.pageSize

        let sortedEntries = entries.sorted { $0.date > $1.date }
        let pagedEntries = MetricDetailView.paged(entries: sortedEntries, page: page, pageSize: pageSize)
        let hasMore = pagedEntries.count < entries.count
        
        // Filter time series to last year for chart performance
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let filteredTimeSeries = timeSeries.map { series in
            TimeSeriesData.TimeSeries(
                name: series.name,
                data: series.data.filter { $0.date >= oneYearAgo }
            )
        }

        List {
            chartSection(configuration: configuration, series: filteredTimeSeries)
            listSection(configuration: configuration, entries: entries, pagedEntries: pagedEntries, hasMore: hasMore)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(configuration.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .onFirstTask {
            await presenter.onAppear()
        }
        .onChange(of: entries.count) { _, _ in
            page = 1
        }
    }
    
    @ViewBuilder
    private func chartSection(configuration: MetricConfiguration, series: [TimeSeriesData.TimeSeries]) -> some View {
        Section {
            VStack(alignment: .leading) {
                if let contributionData = presenter.contributionChartData {
                    ContributionChartView(
                        data: contributionData,
                        rows: 3,
                        columns: 10,
                        targetValue: 1.0,
                        blockColor: configuration.chartColor ?? .green,
                        blockBackgroundColor: .background,
                        rectangleWidth: .infinity,
                        endDate: .now,
                        showsCaptioning: false
                    )
                    .frame(height: 300)
                } else if let customChart = presenter.customChartView {
                    customChart
                        .frame(height: 300)
                } else {
                    NewHistoryChart(
                        series: series,
                        yAxisSuffix: configuration.isMacrosChart ? (configuration.macrosYAxisSuffix ?? " g") : configuration.yAxisSuffix,
                        chartType: configuration.chartType ?? .line,
                        chartColor: configuration.chartColor
                    )
                    .frame(height: 300)
                }
            }
            .listRowInsets(.horizontal, 0)
            .removeListRowFormatting()
            .listRowSeparator(.hidden)
        }
        .listSectionMargins(.horizontal, 0)
        .listSectionMargins(.top, 0)
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
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    private func listSection(configuration: MetricConfiguration, entries: [Presenter.Entry], pagedEntries: ArraySlice<Presenter.Entry>, hasMore: Bool) -> some View {
        if entries.isEmpty {
            Section {
                ContentUnavailableView(
                    configuration.emptyStateMessage,
                    systemImage: "info.circle"
                )
            } header: {
                Text(configuration.sectionHeader)
            }
        } else {
            let grouped = groupedByMonth(Array(pagedEntries))
            ForEach(grouped.sorted(by: { $0.key > $1.key }), id: \.key) { group in
                Section {
                    ForEach(group.entries) { entry in
                        Label(
                            configuration.isMacrosChart
                                ? "\(entry.displayLabel) \(entry.displayValue)"
                                : "\(entry.displayLabel) \(entry.displayValue) \(configuration.yAxisSuffix)",
                            systemImage: entry.systemImageName
                        )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await presenter.onDeleteEntry(entry) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(group.title)
                }
            }

            if hasMore {
                Section {
                    Button {
                        page += 1
                    } label: {
                        HStack {
                            Text("Load more")
                            Spacer()
                            Text("\(pagedEntries.count) of \(entries.count)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }

    private func groupedByMonth(_ entries: [Presenter.Entry]) -> [MonthGroup<Presenter.Entry>] {
        let calendar = Calendar.current
        var groups: [DateComponents: [Presenter.Entry]] = [:]
        var order: [DateComponents] = []

        for entry in entries {
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            if groups[components] == nil {
                order.append(components)
            }
            groups[components, default: []].append(entry)
        }

        return order.compactMap { components in
            guard let entries = groups[components],
                  let date = calendar.date(from: components) else { return nil }
            let title = date.formatted(.dateTime.month(.wide).year())
            let key = String(format: "%04d-%02d", components.year ?? 0, components.month ?? 0)
            return MonthGroup(key: key, title: title, entries: entries)
        }
    }

    private static func paged(entries: [Presenter.Entry], page: Int, pageSize: Int?) -> ArraySlice<Presenter.Entry> {
        guard let pageSize, pageSize > 0 else { return entries[entries.startIndex..<entries.endIndex] }
        let safePage = max(1, page)
        let limit = min(entries.count, safePage * pageSize)
        return entries.prefix(limit)
    }
}

private struct MonthGroup<Entry: MetricEntry> {
    let key: String
    let title: String
    let entries: [Entry]
}
