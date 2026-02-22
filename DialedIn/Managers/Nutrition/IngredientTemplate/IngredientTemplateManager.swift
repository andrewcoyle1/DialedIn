//
//  IngredientTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
@MainActor
class IngredientTemplateManager {
    
    private let remote: RemoteIngredientTemplateService
    private let local: LocalIngredientTemplatePersistence
    private let logManager: LogManager?
    
    init(services: IngredientTemplateServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
    }

    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) throws {
        logManager?.trackEvent(event: Event.addLocalStart(id: ingredient.id))
        do {
            try local.addLocalIngredientTemplate(ingredient: ingredient)
            logManager?.trackEvent(event: Event.addLocalSuccess(id: ingredient.id))
        } catch {
            logManager?.trackEvent(event: Event.addLocalFail(id: ingredient.id, error: error))
            throw error
        }
    }
    
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try local.getLocalIngredientTemplate(id: id)
    }
    
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try local.getLocalIngredientTemplates(ids: ids)
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try local.getAllLocalIngredientTemplates()
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        logManager?.trackEvent(event: Event.createStart(id: ingredient.id, hasImage: image != nil))
        do {
            try await remote.createIngredientTemplate(ingredient: ingredient, image: image)
            logManager?.trackEvent(event: Event.createSuccess(id: ingredient.id))
        } catch {
            logManager?.trackEvent(event: Event.createFail(id: ingredient.id, error: error))
            throw error
        }
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await remote.getIngredientTemplate(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplatesByName(name: name)
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await remote.getIngredientTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int = 10) async throws -> [IngredientTemplateModel] {
        try await remote.getTopIngredientTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await remote.incrementIngredientTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await remote.removeAuthorIdFromIngredientTemplate(id: id)
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await remote.removeAuthorIdFromAllIngredientTemplates(id: id)
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await remote.bookmarkIngredientTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await remote.favouriteIngredientTemplate(id: id, isFavourited: isFavourited)
    }
}
 
extension IngredientTemplateManager {
    // MARK: - Events
    enum Event: LoggableEvent {
        case createStart(id: String, hasImage: Bool)
        case createSuccess(id: String)
        case createFail(id: String, error: Error)
        case addLocalStart(id: String)
        case addLocalSuccess(id: String)
        case addLocalFail(id: String, error: Error)
        
        var eventName: String {
            switch self {
            case .createStart:      return "IngrTempMan_Create_Start"
            case .createSuccess:    return "IngrTempMan_Create_Success"
            case .createFail:       return "IngrTempMan_Create_Fail"
            case .addLocalStart:    return "IngrTempMan_AddLocal_Start"
            case .addLocalSuccess:  return "IngrTempMan_AddLocal_Success"
            case .addLocalFail:     return "IngrTempMan_AddLocal_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .createStart(let id, let hasImage):
                return ["id": id, "has_image": hasImage]
            case .createSuccess(let id):
                return ["id": id]
            case .createFail(let id, let error):
                return ["id": id, "error": String(describing: error)]
            case .addLocalStart(let id):
                return ["id": id]
            case .addLocalSuccess(let id):
                return ["id": id]
            case .addLocalFail(let id, let error):
                return ["id": id, "error": String(describing: error)]
            }
        }
        
        var type: LogType {
            switch self {
            case .createFail, .addLocalFail:
                return .warning
            default:
                return .analytic
            }
        }
    }

}

extension CoreInteractor {
    // MARK: IngredientTemplateManager
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) throws {
        try ingredientTemplateManager.addLocalIngredientTemplate(ingredient: ingredient)
    }
    
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try ingredientTemplateManager.getLocalIngredientTemplate(id: id)
    }
    
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try ingredientTemplateManager.getLocalIngredientTemplates(ids: ids)
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try ingredientTemplateManager.getAllLocalIngredientTemplates()
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        try await ingredientTemplateManager.createIngredientTemplate(ingredient: ingredient, image: image)
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await ingredientTemplateManager.getIngredientTemplate(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplatesByName(name: name)
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getIngredientTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int = 10) async throws -> [IngredientTemplateModel] {
        try await ingredientTemplateManager.getTopIngredientTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await ingredientTemplateManager.incrementIngredientTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await ingredientTemplateManager.removeAuthorIdFromIngredientTemplate(id: id)
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await ingredientTemplateManager.removeAuthorIdFromAllIngredientTemplates(id: id)
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await ingredientTemplateManager.bookmarkIngredientTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await ingredientTemplateManager.favouriteIngredientTemplate(id: id, isFavourited: isFavourited)
    }

}
