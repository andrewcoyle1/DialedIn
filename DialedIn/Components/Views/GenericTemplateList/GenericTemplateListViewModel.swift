//
//  GenericTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

/// Generic view model for template list views
@Observable
@MainActor
class GenericTemplateListViewModel<Template: TemplateModel> {
    private let fetchTemplatesByIds: ([String], Int) async throws -> [Template]
    private let fetchTopTemplates: (Int) async throws -> [Template]
    private let configuration: TemplateListConfiguration<Template>
    
    let templateIds: [String]?
    
    private(set) var templates: [Template] = []
    private(set) var isLoading: Bool = false
    var path: [TabBarPathOption] = []
    var showAlert: AnyAppAlert?
    
    init(
        configuration: TemplateListConfiguration<Template>,
        templateIds: [String]?,
        fetchTemplatesByIds: @escaping ([String], Int) async throws -> [Template],
        fetchTopTemplates: @escaping (Int) async throws -> [Template] = { _ in [] }
    ) {
        self.configuration = configuration
        self.templateIds = templateIds
        self.fetchTemplatesByIds = fetchTemplatesByIds
        self.fetchTopTemplates = fetchTopTemplates
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
                let fetchedTemplates = try await fetchTemplatesByIds(templateIds, templateIds.count)
                templates = fetchedTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            } else {
                // Load top templates
                let top = try await fetchTopTemplates(20)
                templates = top
            }
        } catch {
            showAlert = AnyAppAlert(
                title: configuration.errorTitle,
                subtitle: configuration.errorSubtitle
            )
        }
        
        isLoading = false
    }
    
    var title: String {
        templateIds != nil ? configuration.title : configuration.title
    }
    
    func navigationDestination(for template: Template) -> TabBarPathOption {
        configuration.navigationDestination(template)
    }
}
