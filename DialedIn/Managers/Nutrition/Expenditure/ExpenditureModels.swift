//
//  ExpenditureModels.swift
//  DialedIn
//

import Foundation

/// One calendar day of the three things the expenditure engine reads.
///
/// A day with meal logs but no calories in them is `intakeKcal == 0`, not `nil`: the user logged,
/// they just ate nothing the app knows about. Only a day with no meal log at all is unlogged, and
/// that distinction is the whole of `minLoggedFraction`.
struct DailySample: Equatable, Sendable {
    /// Start of day, in the calendar the samples were built with.
    let day: Date
    let intakeKcal: Double?
    let weightKg: Double?
    let steps: Int?

    init(day: Date, intakeKcal: Double? = nil, weightKg: Double? = nil, steps: Int? = nil) {
        self.day = day
        self.intakeKcal = intakeKcal
        self.weightKg = weightKg
        self.steps = steps
    }
}

/// The engine's answer for one day. Deterministic given its inputs, so nothing here is persisted.
struct ExpenditureEstimate: Equatable, Sendable {

    /// Where the day's figure came from, which is what the status line on the settings screen says.
    enum Source: String, Equatable, Sendable {
        /// The formula estimate, carried forward because the window is not yet sufficient.
        case prior
        /// The energy-balance estimate.
        case adaptive
        /// `calculationMode == .fixed`; the user asked for the number to stand still.
        case fixed
    }

    let day: Date
    /// What the app uses, rounded to the nearest kilocalorie.
    let kcal: Double
    let source: Source
    /// True while the window is insufficient, so the UI can say the figure is still a guess.
    let isProvisional: Bool
    let trendWeightKg: Double?
    /// `deltaTrendKg · 7 / spanDays` over the window; nil when provisional.
    let weeklyTrendChangeKg: Double?
    let loggedDays: Int
    let weighInCount: Int
    /// The number of sample days actually present in the window, not the constant.
    let windowDays: Int
    /// The step nowcast already included in `kcal`; 0 unless it applied.
    let stepAdjustmentKcal: Double
}
