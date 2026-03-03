//
//  NutritionLibraryPickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol NutritionLibraryPickerInteractor: GlobalInteractor {
    var ingredientTemplates: [IngredientTemplateModel] { get }
}

extension CoreInteractor: NutritionLibraryPickerInteractor { }
