//
//  MockIngredientTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockIngredientTemplateServices: IngredientTemplateServices {
    let remote: RemoteIngredientTemplateService
    let local: LocalIngredientTemplatePersistence
    
    init(ingredients: [IngredientTemplateModel] = IngredientTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockIngredientTemplateService(ingredients: ingredients, delay: delay, showError: showError)
        self.local = MockIngredientTemplatePersistence(ingredients: ingredients, showError: showError)
    }
}
