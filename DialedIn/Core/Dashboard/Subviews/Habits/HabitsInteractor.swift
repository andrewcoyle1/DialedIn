import SwiftUI

@MainActor
protocol HabitsInteractor {
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
}

extension CoreInteractor: HabitsInteractor { }
