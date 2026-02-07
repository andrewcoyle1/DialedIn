import SwiftUI

@MainActor
protocol InsightsAndAnalyticsInteractor {
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    var measurementHistory: [BodyMeasurementEntry] { get }
    var currentUser: UserModel? { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func estimateTDEE(user: UserModel?) -> Double
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
}

extension CoreInteractor: InsightsAndAnalyticsInteractor { }
