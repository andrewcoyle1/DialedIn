//
//  WorkoutTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol WorkoutTemplateListInteractor {
    func getWorkoutTemplates(ids: [String], limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
}

extension CoreInteractor: WorkoutTemplateListInteractor { }

@Observable
@MainActor
class WorkoutTemplateListViewModel {
    private let interactor: WorkoutTemplateListInteractor
    
    private(set) var isLoading: Bool = false
    private(set) var templates: [WorkoutTemplateModel] = []

    var showAlert: AnyAppAlert?
    
    init(interactor: WorkoutTemplateListInteractor) {
        self.interactor = interactor
    }
    
    func loadTemplates(templateIds: [String]?) async {
        isLoading = true
        
        do {
            if let templateIds = templateIds {
                // Load user's specific templates
                guard !templateIds.isEmpty else {
                    isLoading = false
                    return
                }
                let fetchedTemplates = try await interactor.getWorkoutTemplates(ids: templateIds, limitTo: templateIds.count)
                templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            } else {
                // Load top templates
                let top = try await interactor.getTopWorkoutTemplatesByClicks(limitTo: 20)
                templates = top
            }
        } catch {
            showAlert = AnyAppAlert(title: "Unable to Load Workouts", subtitle: "Please try again later.")
        }
        
        isLoading = false
    }
}
