import SwiftUI

@MainActor
protocol RecipeListBuilderInteractor {
    var currentUser: UserModel? { get }
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel]
    func incrementRecipeTemplateInteraction(id: String) async throws
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: RecipeListBuilderInteractor { }
