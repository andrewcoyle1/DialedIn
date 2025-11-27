//
//  AddIngredientModalPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class AddIngredientModalPresenter {
    private let interactor: AddIngredientModalInteractor
    private let router: AddIngredientModalRouter

    private(set) var ingredients: [IngredientTemplateModel] = []
    private(set) var isLoading: Bool = false
    var errorMessage: String?
    var searchText: String = ""
    
    init(
        interactor: AddIngredientModalInteractor,
        router: AddIngredientModalRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onIngredientPressed(ingredient: IngredientTemplateModel, selectedIngredients: inout [IngredientTemplateModel]) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
    
    func onDismissPressed(onDismiss: () -> Void) {
        onDismiss()
    }
    
    func loadIngredients() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // Load top ingredients when not searching
            let loadedIngredients = try await interactor.getTopIngredientTemplatesByClicks(limitTo: 50)
            await MainActor.run {
                ingredients = loadedIngredients
                isLoading = false
            }
        } catch {
            // Fallback to local ingredients if remote fails
            do {
                let localIngredients = try interactor.getAllLocalIngredientTemplates()
                await MainActor.run {
                    ingredients = localIngredients
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load ingredients. Please check your connection and try again."
                }
            }
        }
    }
    
    func searchIngredients() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If search is empty, reload top ingredients
        guard !query.isEmpty else {
            await loadIngredients()
            return
        }
        
        // Don't search for very short queries to avoid too many API calls
        guard query.count >= 2 else { return }
        
        do {
            let searchResults = try await interactor.getIngredientTemplatesByName(name: query)
            await MainActor.run {
                ingredients = searchResults
            }
        } catch {
            // Don't show error for search failures, just keep current results
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
