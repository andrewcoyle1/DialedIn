//
//  RecipeTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol RecipeTemplateServices {
    var remote: RemoteRecipeTemplateService { get }
    var local: LocalRecipeTemplatePersistence { get }
}

struct MockRecipeTemplateServices: RecipeTemplateServices {
    let remote: RemoteRecipeTemplateService
    let local: LocalRecipeTemplatePersistence
    
    @MainActor
    init(recipes: [RecipeTemplateModel] = RecipeTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockRecipeTemplateService(recipes: recipes, delay: delay, showError: showError)
        self.local = MockRecipeTemplatePersistence(recipes: recipes, showError: showError)
    }
}

struct ProductionRecipeTemplateServices: RecipeTemplateServices {
    let remote: RemoteRecipeTemplateService
    let local: LocalRecipeTemplatePersistence
    
    @MainActor
    init() {
        self.remote = FirebaseRecipeTemplateService()
        self.local = SwiftRecipeTemplatePersistence()
    }
}
