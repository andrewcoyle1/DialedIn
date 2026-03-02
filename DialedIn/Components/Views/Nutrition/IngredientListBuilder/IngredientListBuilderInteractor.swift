import SwiftUI

@MainActor
protocol IngredientListBuilderInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var ingredientTemplates: [IngredientTemplateModel] { get }
}

extension CoreInteractor: IngredientListBuilderInteractor { }
