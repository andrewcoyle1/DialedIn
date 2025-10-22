//
//  ExerciseTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseTemplateListViewModel {
    private let exerciseTemplateManager: ExerciseTemplateManager
    
    private(set) var templates: [ExerciseTemplateModel] = []
    private(set) var isLoading: Bool = false
    var path: [NavigationPathOption] = []
    var showAlert: AnyAppAlert?
    
    init(
        container: DependencyContainer
    ) {
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
    }
    
    func loadTemplates(templateIds: [String]) async {
        guard !templateIds.isEmpty else { return }
        isLoading = true
        
        do {
            let fetchedTemplates = try await exerciseTemplateManager.getExerciseTemplates(ids: templateIds, limitTo: templateIds.count)
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
