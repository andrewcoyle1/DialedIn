import SwiftUI

@MainActor
protocol ScaleWeightInteractor {
    var currentUser: UserModel? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
    func updateWeightEntry(entry: BodyMeasurementEntry) async throws
    func dedupeWeightEntriesByDay(userId: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ScaleWeightInteractor { }
