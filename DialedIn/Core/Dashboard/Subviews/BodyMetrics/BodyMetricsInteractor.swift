import SwiftUI

@MainActor
protocol BodyMetricsInteractor {
    func trackEvent(event: LoggableEvent)
    func backfillBodyFatFromHealthKit() async
    var measurementHistory: [BodyMeasurementEntry] { get }
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws
    func uploadImage(image: PlatformImage, path: String) async throws -> URL
    func deleteImage(path: String) async throws
}

extension CoreInteractor: BodyMetricsInteractor { }
