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
