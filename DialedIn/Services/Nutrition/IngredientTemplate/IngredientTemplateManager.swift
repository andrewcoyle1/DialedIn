//
//  IngredientTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
class IngredientTemplateManager: BaseTemplateManager<IngredientTemplateModel> {
    
    private let logManager: LogManager?
    
    init(services: IngredientTemplateServices, logManager: LogManager? = nil) {
        self.logManager = logManager
        super.init(
            addLocal: { try services.local.addLocalIngredientTemplate(ingredient: $0) },
            getLocal: { try services.local.getLocalIngredientTemplate(id: $0) },
            getLocalMany: { try services.local.getLocalIngredientTemplates(ids: $0) },
            getAllLocal: { try services.local.getAllLocalIngredientTemplates() },
            deleteLocal: nil,
            createRemote: { try await services.remote.createIngredientTemplate(ingredient: $0, image: $1) },
            updateRemote: nil,
            deleteRemote: nil,
            getRemote: { try await services.remote.getIngredientTemplate(id: $0) },
            getRemoteMany: { try await services.remote.getIngredientTemplates(ids: $0, limitTo: $1) },
            getByNameRemote: { try await services.remote.getIngredientTemplatesByName(name: $0) },
            getForAuthorRemote: { try await services.remote.getIngredientTemplatesForAuthor(authorId: $0) },
            getTopByClicksRemote: { try await services.remote.getTopIngredientTemplatesByClicks(limitTo: $0) },
            incrementRemote: { try await services.remote.incrementIngredientTemplateInteraction(id: $0) },
            removeAuthorIdRemote: { try await services.remote.removeAuthorIdFromIngredientTemplate(id: $0) },
            removeAuthorIdFromAllRemote: { try await services.remote.removeAuthorIdFromAllIngredientTemplates(id: $0) },
            bookmarkRemote: { try await services.remote.bookmarkIngredientTemplate(id: $0, isBookmarked: $1) },
            favouriteRemote: { try await services.remote.favouriteIngredientTemplate(id: $0, isFavourited: $1) }
        )
    }
    
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
    
    // MARK: - Method Aliases for Backward Compatibility
    
    func addLocalIngredientTemplate(ingredient: IngredientTemplateModel) async throws {
        logManager?.trackEvent(event: Event.addLocalStart(id: ingredient.id))
        do {
            try await addLocalTemplate(ingredient)
            logManager?.trackEvent(event: Event.addLocalSuccess(id: ingredient.id))
        } catch {
            logManager?.trackEvent(event: Event.addLocalFail(id: ingredient.id, error: error))
            throw error
        }
    }
    
    func getLocalIngredientTemplate(id: String) throws -> IngredientTemplateModel {
        try getLocalTemplate(id: id)
    }
    
    func getLocalIngredientTemplates(ids: [String]) throws -> [IngredientTemplateModel] {
        try getLocalTemplates(ids: ids)
    }
    
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel] {
        try getAllLocalTemplates()
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        logManager?.trackEvent(event: Event.createStart(id: ingredient.id, hasImage: image != nil))
        do {
            try await createTemplate(ingredient, image: image)
            logManager?.trackEvent(event: Event.createSuccess(id: ingredient.id))
        } catch {
            logManager?.trackEvent(event: Event.createFail(id: ingredient.id, error: error))
            throw error
        }
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await getTemplate(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        try await getTemplates(ids: ids, limitTo: limitTo)
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        try await getTemplatesByName(name: name)
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await getTemplatesForAuthor(authorId: authorId)
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int = 10) async throws -> [IngredientTemplateModel] {
        try await getTopTemplatesByClicks(limitTo: limitTo)
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await incrementTemplateInteraction(id: id)
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await removeAuthorIdFromTemplate(id: id)
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        try await removeAuthorIdFromAllTemplates(id: id)
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await bookmarkTemplate(id: id, isBookmarked: isBookmarked)
    }
    
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await favouriteTemplate(id: id, isFavourited: isFavourited)
    }
}
 
