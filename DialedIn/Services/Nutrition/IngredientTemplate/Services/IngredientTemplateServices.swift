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
