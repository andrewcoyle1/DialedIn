//
//  LocalTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

/// Generic protocol for local template persistence
/// Provides a common interface for working with local storage of templates
@MainActor
protocol LocalTemplatePersistence {
    associatedtype Model: TemplateModel
    
    func addLocalTemplate(_ template: Model) throws
    func getLocalTemplate(id: String) throws -> Model
    func getLocalTemplates(ids: [String]) throws -> [Model]
    func getAllLocalTemplates() throws -> [Model]
    func bookmarkTemplate(id: String, isBookmarked: Bool) throws
}
