import SwiftUI

@MainActor
protocol MuscleGroupsInteractor {
    func trackEvent(event: LoggableEvent)
    var auth: UserAuthInfo? { get }
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
}

extension CoreInteractor: MuscleGroupsInteractor { }
