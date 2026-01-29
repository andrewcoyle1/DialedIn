//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

/// Generic protocol for remote template services
/// Provides a common interface for working with remote storage of templates
protocol RemoteTemplateService {
    associatedtype Model: TemplateModel
    
    func createTemplate(_ template: Model, image: PlatformImage?) async throws
    func getTemplate(id: String) async throws -> Model
    func getTemplates(ids: [String], limitTo: Int) async throws -> [Model]
    func getTemplatesByName(name: String) async throws -> [Model]
    func getTemplatesForAuthor(authorId: String) async throws -> [Model]
    func getTopTemplatesByClicks(limitTo: Int) async throws -> [Model]
    func incrementTemplateInteraction(id: String) async throws
    func removeAuthorIdFromTemplate(id: String) async throws
    func removeAuthorIdFromAllTemplates(id: String) async throws
    func bookmarkTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteTemplate(id: String, isFavourited: Bool) async throws
}

// Extension for optional update and delete methods
extension RemoteTemplateService {
    func updateTemplate(_ template: Model, image: PlatformImage?) async throws {
        throw NSError(domain: "RemoteTemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Update not supported"])
    }
    
    func deleteTemplate(id: String) async throws {
        throw NSError(domain: "RemoteTemplateService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete not supported"])
    }
}
