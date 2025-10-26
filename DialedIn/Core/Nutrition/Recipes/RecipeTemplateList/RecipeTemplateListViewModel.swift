//
//  RecipeTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol RecipeTemplateListInteractor {
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
}

extension CoreInteractor: RecipeTemplateListInteractor { }

@Observable
@MainActor
class RecipeTemplateListViewModel {
    private let interactor: RecipeTemplateListInteractor
    private let templateIds: [String]

    private(set) var templates: [RecipeTemplateModel] = []
    var path: [NavigationPathOption] = []
    private(set) var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    init(
        interactor: RecipeTemplateListInteractor,
        templateIds: [String]
    ) {
        self.interactor = interactor
        self.templateIds = templateIds
    }
    
    func loadTemplates() async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await interactor.getRecipeTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load recipes",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}
