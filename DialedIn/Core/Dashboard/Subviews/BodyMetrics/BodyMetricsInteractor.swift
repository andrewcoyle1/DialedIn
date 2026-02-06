import SwiftUI

@MainActor
protocol BodyMetricsInteractor {
    func trackEvent(event: LoggableEvent)
    func backfillBodyFatFromHealthKit() async
    var weightHistory: [WeightEntry] { get }
    func readAllLocalWeightEntries() throws -> [WeightEntry]
}

extension CoreInteractor: BodyMetricsInteractor { }
