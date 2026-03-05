import SwiftUI

@MainActor
protocol FoodDefinitionInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveIngredientTemplate(_ ingredient: IngredientTemplateModel, image: PlatformImage?) async throws
}

extension CoreInteractor: FoodDefinitionInteractor { }
