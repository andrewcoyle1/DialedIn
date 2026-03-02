import SwiftUI

@MainActor
protocol RecipeListBuilderInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var userRecipeTemplates: [RecipeTemplateModel] { get }
}

extension CoreInteractor: RecipeListBuilderInteractor { }
