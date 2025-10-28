//
//  ExerciseTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ExerciseTemplateListInteractor {
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseTemplateModel]
}

extension CoreInteractor: ExerciseTemplateListInteractor { }

@Observable
@MainActor
class ExerciseTemplateListViewModel {
    private let interactor: ExerciseTemplateListInteractor
    
    let templateIds: [String]?

    private(set) var templates: [ExerciseTemplateModel] = []
    private(set) var isLoading: Bool = false
    var path: [NavigationPathOption] = []
    var showAlert: AnyAppAlert?
    
    init(
        interactor: ExerciseTemplateListInteractor,
        templateIds: [String]?
    ) {
        self.interactor = interactor
        self.templateIds = templateIds
    }
    
    func loadTemplates(templateIds: [String]) async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await interactor.getExerciseTemplates(ids: templateIds, limitTo: templateIds.count)
            templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            showAlert = AnyAppAlert(
                title: "Unable to load exercises",
                subtitle: "Please check your internet connection and try again."
            )
        }
        
        isLoading = false
    }
}
