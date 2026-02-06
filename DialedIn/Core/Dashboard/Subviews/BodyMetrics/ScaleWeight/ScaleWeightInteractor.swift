import SwiftUI

@MainActor
protocol ScaleWeightInteractor {
    var currentUser: UserModel? { get }
    var weightHistory: [WeightEntry] { get }
    func readAllLocalWeightEntries() throws -> [WeightEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [WeightEntry]
    func dedupeWeightEntriesByDay(userId: String) async throws 
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ScaleWeightInteractor { }
