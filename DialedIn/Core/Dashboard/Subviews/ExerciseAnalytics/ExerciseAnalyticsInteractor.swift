import SwiftUI

@MainActor
protocol ExerciseAnalyticsInteractor {
    func trackEvent(event: LoggableEvent)
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func getSystemExerciseTemplates() throws -> [ExerciseModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel]
}

extension CoreInteractor: ExerciseAnalyticsInteractor { }
