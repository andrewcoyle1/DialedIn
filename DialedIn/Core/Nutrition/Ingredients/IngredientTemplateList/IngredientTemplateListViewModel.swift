//
//  IngredientTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol IngredientTemplateListInteractor {
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
}

extension CoreInteractor: IngredientTemplateListInteractor { }

@Observable
@MainActor
class IngredientTemplateListViewModel {
    private let interactor: IngredientTemplateListInteractor
    private let templateIds: [String]

    private(set) var templates: [IngredientTemplateModel] = []
    var path: [NavigationPathOption] = []
    private(set) var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    init(
        interactor: IngredientTemplateListInteractor,
        templateIds: [String]
    ) {
        self.interactor = interactor
        self.templateIds = templateIds
    }
    
    func loadTemplates() async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await interactor.getIngredientTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load ingredients",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}
