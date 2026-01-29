//
//  MockRecipeTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockRecipeTemplateServices: RecipeTemplateServices {
    let remote: RemoteRecipeTemplateService
    let local: LocalRecipeTemplatePersistence
    
    init(recipes: [RecipeTemplateModel] = RecipeTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockRecipeTemplateService(recipes: recipes, delay: delay, showError: showError)
        self.local = MockRecipeTemplatePersistence(recipes: recipes, showError: showError)
    }
}
