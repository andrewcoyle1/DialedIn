import SwiftUI

@MainActor
protocol IngredientListBuilderInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func incrementIngredientTemplateInteraction(id: String) async throws
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel]
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
}

extension CoreInteractor: IngredientListBuilderInteractor { }
