import SwiftUI

@MainActor
protocol HabitsInteractor {
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func getDailyTotals(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, totals: DailyMacroTarget)]
}

extension CoreInteractor: HabitsInteractor { }
