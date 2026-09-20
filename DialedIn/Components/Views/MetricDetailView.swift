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
    @State private var page: Int = 1
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
        let pageSize = configuration.pageSize

        let sortedEntries = entries.sorted { $0.date > $1.date }
        let pagedEntries = MetricDetailView.paged(entries: sortedEntries, page: page, pageSize: pageSize)
        let hasMore = pagedEntries.count < entries.count
        
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
                    listSection(configuration: configuration, entries: entries, pagedEntries: pagedEntries, hasMore: hasMore)
                }
            } else {
                ChartScreen(title: configuration.title) {
                    chart(configuration: configuration, series: timeSeries)
                } sections: {
                    listSection(configuration: configuration, entries: entries, pagedEntries: pagedEntries, hasMore: hasMore)
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
        .onChange(of: entries.count) { _, _ in
            page = 1
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
    
    @ViewBuilder
    private func listSection(configuration: MetricConfiguration, entries: [Presenter.Entry], pagedEntries: ArraySlice<Presenter.Entry>, hasMore: Bool) -> some View {
        if entries.isEmpty {
            emptySection(configuration: configuration)
        } else {
            let grouped = groupedByMonth(Array(pagedEntries))
            ForEach(grouped.sorted(by: { $0.key > $1.key }), id: \.key) { group in
                Section {
                    ForEach(group.entries) { entry in
                        entryRow(entry, configuration: configuration)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if presenter.supportsDeletion {
                                Button(role: .destructive) {
                                    Task { await presenter.onDeleteEntry(entry) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
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

    /// Date on the leading edge, value on the trailing edge. The whole row used to be one
    /// concatenated string — `"12 Jan 2026 72.4  kg"` — so nothing lined up down the list and the
    /// chart's axis suffix brought its leading space along with it.
    private func entryRow(_ entry: Presenter.Entry, configuration: MetricConfiguration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Label(entry.displayLabel, systemImage: entry.systemImageName)

            Spacer(minLength: 12)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                // A macro row carries three values ("148g P · 214g C · 69.7g F"). Wrapping it broke
                // the line mid-item and left rows of uneven height, so it scales down to fit on one
                // line instead.
                Text(presenter.displayValue(for: entry))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !configuration.unitText.isEmpty {
                    Text(configuration.unitText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
