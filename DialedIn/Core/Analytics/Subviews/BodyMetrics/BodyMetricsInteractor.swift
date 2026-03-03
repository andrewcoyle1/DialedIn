import SwiftUI

@MainActor
protocol BodyMetricsInteractor: GlobalInteractor {
    func backfillBodyFatFromHealthKit() async
    var bodyMeasurements: [BodyMeasurementEntry] { get }
    func saveBodyMeasurement(bodyMeasurement: BodyMeasurementEntry) async throws
    func uploadImage(image: PlatformImage, path: String) async throws -> URL
    func deleteImage(path: String) async throws
}

extension CoreInteractor: BodyMetricsInteractor { }
