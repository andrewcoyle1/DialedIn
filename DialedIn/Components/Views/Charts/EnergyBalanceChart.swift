//
//  EnergyBalanceChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import SwiftUI
import Charts

/// The thumbnail on the Energy Balance cards: the last week's intake as bars with expenditure drawn
/// over them, with no axes, picker or selection. The full screen behind the card draws the same
/// shape with QuickCharts' `ComboChart`, which brings the ranges, header and callout with it.
struct EnergyBalanceChart: View {

    let expenditure: TimeSeries
    let energyIntake: TimeSeries

    /// How many days the thumbnail shows.
    private static let visibleDays = 7

    private let expenditurePoints: [TimeSeriesDatapoint]
    private let intakePoints: [TimeSeriesDatapoint]
    private let xAxisDomain: ClosedRange<Date>

    init(expenditure: TimeSeries, energyIntake: TimeSeries) {
        self.expenditure = expenditure
        self.energyIntake = energyIntake

        // `sortedByDate` is cached on `TimeSeries`; the window is its tail. One extra expenditure
        // point so the line reaches the leading edge rather than starting inside it.
        let expenditurePoints = Array(expenditure.sortedByDate.suffix(Self.visibleDays + 1))
        let intakePoints = Array(energyIntake.sortedByDate.suffix(Self.visibleDays))
        self.expenditurePoints = expenditurePoints
        self.intakePoints = intakePoints

        // Both arrays are sorted, so the extremes are their first and last elements.
        let earliest = [expenditurePoints.first?.date, intakePoints.first?.date].compactMap { $0 }.min()
        let latest = [expenditurePoints.last?.date, intakePoints.last?.date].compactMap { $0 }.max()
        if let earliest, let latest, earliest < latest {
            // Half a day either side, so the first and last bars aren't clipped in half.
            let padding: TimeInterval = 12 * 60 * 60
            self.xAxisDomain = earliest.addingTimeInterval(-padding)...latest.addingTimeInterval(padding)
        } else {
            let fallback = Date()
            self.xAxisDomain = fallback...fallback.addingTimeInterval(86_400)
        }
    }

    var body: some View {
        Chart {
            ForEach(intakePoints) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
            }
            .foregroundStyle(Self.intakeColor)

            ForEach(expenditurePoints) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
            }
            .foregroundStyle(Self.expenditureColor)
        }
        .chartXScale(domain: xAxisDomain)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }

    /// The colours the full chart uses, so the card and the screen it opens match.
    static let intakeColor: Color = .blue
    static let expenditureColor: Color = .pink
}

#Preview {
    EnergyBalanceChart(
        expenditure: TimeSeries.last14Days,
        energyIntake: TimeSeries.last14Days
    )
    .frame(width: 350, height: 200)
}
