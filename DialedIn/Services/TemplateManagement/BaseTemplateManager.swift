//
//  BaseTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

/// Base class for template managers that provides default implementations
/// for common CRUD operations to reduce code duplication
@MainActor
class BaseTemplateManager<Model: Identifiable & Hashable> where Model.ID == String {
    
    // MARK: - Stored operation closures
    private let addLocalClosure: (Model) throws -> Void
    private let getLocalClosure: (String) throws -> Model
    private let getLocalManyClosure: ([String]) throws -> [Model]
    private let getAllLocalClosure: () throws -> [Model]
    private let deleteLocalClosure: ((String) throws -> Void)?
    
    private let createRemoteClosure: (Model, PlatformImage?) async throws -> Void
    private let updateRemoteClosure: ((Model, PlatformImage?) async throws -> Void)?
    private let deleteRemoteClosure: ((String) async throws -> Void)?
    private let getRemoteClosure: (String) async throws -> Model
    private let getRemoteManyClosure: ([String], Int) async throws -> [Model]
    private let getByNameRemoteClosure: (String) async throws -> [Model]
    private let getForAuthorRemoteClosure: (String) async throws -> [Model]
    private let getTopByClicksRemoteClosure: (Int) async throws -> [Model]
    private let incrementRemoteClosure: (String) async throws -> Void
    private let removeAuthorIdRemoteClosure: (String) async throws -> Void
    private let removeAuthorIdFromAllRemoteClosure: (String) async throws -> Void
    private let bookmarkRemoteClosure: (String, Bool) async throws -> Void
    private let favouriteRemoteClosure: (String, Bool) async throws -> Void
    
    init(
        addLocal: @escaping (Model) throws -> Void,
        getLocal: @escaping (String) throws -> Model,
        getLocalMany: @escaping ([String]) throws -> [Model],
        getAllLocal: @escaping () throws -> [Model],
        deleteLocal: ((String) throws -> Void)? = nil,
        createRemote: @escaping (Model, PlatformImage?) async throws -> Void,
        updateRemote: ((Model, PlatformImage?) async throws -> Void)? = nil,
        deleteRemote: ((String) async throws -> Void)? = nil,
        getRemote: @escaping (String) async throws -> Model,
        getRemoteMany: @escaping ([String], Int) async throws -> [Model],
        getByNameRemote: @escaping (String) async throws -> [Model],
        getForAuthorRemote: @escaping (String) async throws -> [Model],
        getTopByClicksRemote: @escaping (Int) async throws -> [Model],
        incrementRemote: @escaping (String) async throws -> Void,
        removeAuthorIdRemote: @escaping (String) async throws -> Void,
        removeAuthorIdFromAllRemote: @escaping (String) async throws -> Void,
        bookmarkRemote: @escaping (String, Bool) async throws -> Void,
        favouriteRemote: @escaping (String, Bool) async throws -> Void
    ) {
        self.addLocalClosure = addLocal
        self.getLocalClosure = getLocal
        self.getLocalManyClosure = getLocalMany
        self.getAllLocalClosure = getAllLocal
        self.deleteLocalClosure = deleteLocal
        
        self.createRemoteClosure = createRemote
        self.updateRemoteClosure = updateRemote
        self.deleteRemoteClosure = deleteRemote
        self.getRemoteClosure = getRemote
        self.getRemoteManyClosure = getRemoteMany
        self.getByNameRemoteClosure = getByNameRemote
        self.getForAuthorRemoteClosure = getForAuthorRemote
        self.getTopByClicksRemoteClosure = getTopByClicksRemote
        self.incrementRemoteClosure = incrementRemote
        self.removeAuthorIdRemoteClosure = removeAuthorIdRemote
        self.removeAuthorIdFromAllRemoteClosure = removeAuthorIdFromAllRemote
        self.bookmarkRemoteClosure = bookmarkRemote
        self.favouriteRemoteClosure = favouriteRemote
    }
    
    // MARK: - Local Operations
    func addLocalTemplate(_ template: Model) async throws {
        try addLocalClosure(template)
        try await incrementTemplateInteraction(id: template.id)
    }
    
    func getLocalTemplate(id: String) throws -> Model {
        try getLocalClosure(id)
    }
    
    func getLocalTemplates(ids: [String]) throws -> [Model] {
        try getLocalManyClosure(ids)
    }
    
    func getAllLocalTemplates() throws -> [Model] {
        try getAllLocalClosure()
    }
    
    func deleteLocalTemplate(id: String) throws {
        try deleteLocalClosure?(id)
    }
    
    // MARK: - Remote Operations
    func createTemplate(_ template: Model, image: PlatformImage?) async throws {
        try await createRemoteClosure(template, image)
    }
    
    func updateTemplate(_ template: Model, image: PlatformImage?) async throws {
        guard let update = updateRemoteClosure else {
            throw NSError(domain: "BaseTemplateManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Update not supported for this template type"]) 
        }
        try await update(template, image)
    }
    
    func deleteTemplate(id: String) async throws {
        guard let delete = deleteRemoteClosure else {
            throw NSError(domain: "BaseTemplateManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete not supported for this template type"]) 
        }
        try await delete(id)
    }
    
    func getTemplate(id: String) async throws -> Model {
        try await getRemoteClosure(id)
    }
    
    func getTemplates(ids: [String], limitTo: Int = 20) async throws -> [Model] {
        try await getRemoteManyClosure(ids, limitTo)
    }
    
    func getTemplatesByName(name: String) async throws -> [Model] {
        try await getByNameRemoteClosure(name)
    }
    
    func getTemplatesForAuthor(authorId: String) async throws -> [Model] {
        try await getForAuthorRemoteClosure(authorId)
    }
    
    func getTopTemplatesByClicks(limitTo: Int = 10) async throws -> [Model] {
        try await getTopByClicksRemoteClosure(limitTo)
    }
    
    // MARK: - Interaction Operations
    func incrementTemplateInteraction(id: String) async throws {
        try await incrementRemoteClosure(id)
    }
    
    func removeAuthorIdFromTemplate(id: String) async throws {
        try await removeAuthorIdRemoteClosure(id)
    }
    
    func removeAuthorIdFromAllTemplates(id: String) async throws {
        try await removeAuthorIdFromAllRemoteClosure(id)
    }
    
    func bookmarkTemplate(id: String, isBookmarked: Bool) async throws {
        try await bookmarkRemoteClosure(id, isBookmarked)
    }
    
    func favouriteTemplate(id: String, isFavourited: Bool) async throws {
        try await favouriteRemoteClosure(id, isFavourited)
    }
}
