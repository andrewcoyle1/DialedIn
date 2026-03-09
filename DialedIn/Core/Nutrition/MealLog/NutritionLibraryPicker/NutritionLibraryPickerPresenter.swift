//
//  NutritionLibraryPickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class NutritionLibraryPickerPresenter {
    private let interactor: NutritionLibraryPickerInteractor
    private let router: NutritionLibraryPickerRouter

    private(set) var mode: NutritionPickerMode = .search
    var searchText: String = ""
    private(set) var recipes: [RecipeTemplateModel] = []

    var foods: [FoodModel] {
        interactor.foods
            .filter {
                $0.name == searchText
            }
    }
    
    init(
        interactor: NutritionLibraryPickerInteractor,
        router: NutritionLibraryPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func onModePressed(_ mode: NutritionPickerMode) {
        self.mode = mode
    }
    
    func navToIngredientAmount(_ ingredient: FoodModel, onPick: @escaping (MealItemModel) -> Void) {
        if ingredient.authorId == nil {
            Task { await interactor.saveExternalFood(ingredient) }
        }
        router.showIngredientAmountView(delegate: IngredientAmountDelegate(ingredient: ingredient, onPick: onPick))
    }

    func navToRecipeAmount(_ recipe: RecipeTemplateModel, onPick: @escaping (MealItemModel) -> Void) {
        router.showRecipeAmountView(delegate: RecipeAmountDelegate(recipe: recipe, onPick: onPick))
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "NutritionLibrary_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }
    
#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif
}

enum NutritionPickerMode: String, CaseIterable, DataSyncModelProtocol {
    
    var id: String { self.rawValue }
    
    case barcode
    case search
    case aiScanner
    case quickAdd
    case library
    case describe
    
    var title: String {
        switch self {
        case .barcode: return "Barcode"
        case .search: return "Search"
        case .aiScanner: return "AI"
        case .quickAdd: return "Quick Add"
        case .library: return "Library"
        case .describe: return "Describe"
        }
    }
    
    var systemName: String {
        switch self {
        case .barcode: return "barcode"
        case .search: return "magnifyingglass"
        case .aiScanner: return "wand.and.stars"
        case .quickAdd: return "hare"
        case .library: return "book"
        case .describe: return "pencil"
        }
    }
}
