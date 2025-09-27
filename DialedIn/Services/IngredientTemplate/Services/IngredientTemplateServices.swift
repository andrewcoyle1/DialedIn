//
//  IngredientTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/09/2025.
//

protocol IngredientTemplateServices {
    var remote: RemoteIngredientTemplateService { get }
    var local: LocalIngredientTemplatePersistence { get }
}

struct MockIngredientTemplateServices: IngredientTemplateServices {
    let remote: RemoteIngredientTemplateService
    let local: LocalIngredientTemplatePersistence
    
    init(ingredients: [IngredientTemplateModel] = IngredientTemplateModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.remote = MockIngredientTemplateService(ingredients: ingredients, delay: delay, showError: showError)
        self.local = MockIngredientTemplatePersistence(ingredients: ingredients, showError: showError)
    }
}

struct ProductionIngredientTemplateServices: IngredientTemplateServices {
    let remote: RemoteIngredientTemplateService
    let local: LocalIngredientTemplatePersistence
    
    init() {
        self.remote = FirebaseIngredientTemplateService()
        self.local = SwiftIngredientTemplatePersistence()
    }
}
