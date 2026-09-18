//
//  BodyRatioMetric.swift
//  DialedIn
//

import SwiftUI

/// The two ratios the Body Metrics screen shows. Both are derived rather than logged, so there is
/// nothing to add or delete here — the underlying waist, hip and height entries are edited on their
/// own screens.
enum BodyRatioKind: String, CaseIterable, Identifiable {
    case waistToHeight
    case waistToHip

    var id: String { rawValue }

    var title: String {
        switch self {
        case .waistToHeight: return "Waist to Height"
        case .waistToHip:    return "Waist to Hip"
        }
    }

    /// What has to be recorded before the ratio can be worked out, for the empty state.
    var requirement: String {
        switch self {
        case .waistToHeight: return "Log a waist measurement and set your height to see this ratio."
        case .waistToHip:    return "Log a waist and a hip measurement on the same date to see this ratio."
        }
    }
}

struct BodyRatioDelegate {
    let kind: BodyRatioKind
}

struct BodyRatioEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let ratio: Double

    var displayLabel: String {
        date.formatted(.dateTime.day().month().year())
    }

    var displayValue: String {
        ratio.formatted(.number.precision(.fractionLength(2)))
    }

    var systemImageName: String {
        "divide"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Ratio", date: date, value: ratio)]
    }
}

@Observable
@MainActor
final class BodyRatioPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = BodyRatioEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter
    private let kind: BodyRatioKind

    var entries: [BodyRatioEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.ratio) }
        return [TimeSeriesData.TimeSeries(name: "Ratio", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: kind.title,
            analyticsName: "BodyRatioView_\(kind.rawValue)",
            yAxisSuffix: "",
            seriesNames: ["Ratio"],
            // Derived from other metrics — there is nothing to add or delete on this screen.
            showsAddButton: false,
            sectionHeader: "Entries",
            emptyStateMessage: kind.requirement,
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        kind: BodyRatioKind
    ) {
        self.interactor = interactor
        self.router = router
        self.kind = kind
        self.entries = []
    }

    func onAppear() async {
        entries = Self.entries(
            kind: kind,
            measurements: interactor.bodyMeasurements,
            heightCentimetres: interactor.currentUser?.submittedHeightCentimeters
        )
    }

    func onAddPressed() {
        // Unreachable: `showsAddButton` is false, because a ratio is computed from the waist, hip
        // and height entries rather than logged in its own right.
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    /// Circumferences are stored in inches and height in centimetres, so waist-to-height has to
    /// convert before dividing. Waist-to-hip needs no conversion — both sides are inches, and the
    /// unit cancels.
    static func entries(
        kind: BodyRatioKind,
        measurements: [BodyMeasurementEntry],
        heightCentimetres: Double?
    ) -> [BodyRatioEntry] {
        measurements
            .filter { $0.deletedAt == nil }
            .compactMap { entry -> BodyRatioEntry? in
                guard let waistInches = entry.waistCircumference, waistInches > 0 else { return nil }

                let ratio: Double
                switch kind {
                case .waistToHeight:
                    guard let heightCentimetres, heightCentimetres > 0 else { return nil }
                    ratio = (waistInches * Self.centimetresPerInch) / heightCentimetres
                case .waistToHip:
                    // Same entry on both sides: a waist from today over a hip from last month is
                    // not a ratio of anything.
                    guard let hipInches = entry.hipCircumference, hipInches > 0 else { return nil }
                    ratio = waistInches / hipInches
                }

                return BodyRatioEntry(id: entry.id, date: entry.date, ratio: ratio)
            }
            .sorted { $0.date < $1.date }
    }

    private static let centimetresPerInch: Double = 2.54
}

extension CoreRouter {
    func showBodyRatioView(delegate: BodyRatioDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.bodyRatioView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func bodyRatioView(router: AnyRouter, delegate: BodyRatioDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: BodyRatioPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                kind: delegate.kind
            ),
            themeColor: themeColor
        )
    }
}
