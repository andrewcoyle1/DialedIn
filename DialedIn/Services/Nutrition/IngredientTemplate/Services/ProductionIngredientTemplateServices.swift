//
//  ProductionIngredientTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionIngredientTemplateServices: IngredientTemplateServices {
    let remote: RemoteIngredientTemplateService
    let local: LocalIngredientTemplatePersistence
    
    @MainActor
    init() {
        self.remote = FirebaseIngredientTemplateService()
        self.local = SwiftIngredientTemplatePersistence()
    }
}
