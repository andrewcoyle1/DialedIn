import SwiftUI

@MainActor
protocol ExerciseListBuilderInteractor {
    var currentUser: UserModel? { get }
    func incrementExerciseTemplateInteraction(id: String) async throws
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel]
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseTemplateModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseTemplateModel]
    func getSystemExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExerciseListBuilderInteractor { }
