//
//  ProductionRecipeTemplateServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionRecipeTemplateServices: RecipeTemplateServices {
    let remote: RemoteRecipeTemplateService
    let local: LocalRecipeTemplatePersistence
    
    @MainActor
    init() {
        self.remote = FirebaseRecipeTemplateService()
        self.local = SwiftRecipeTemplatePersistence()
    }
}
