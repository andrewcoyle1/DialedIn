//
//  SwiftStepsPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import SwiftUI
import SwiftData

struct SwiftStepsPersistence: LocalStepsPersistence {

    private let container: ModelContainer

    private var mainContext: ModelContext {
        container.mainContext
    }

    init() {
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.StepsEntriesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("StepsEntries.store")
            } else {
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.StepsEntriesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("StepsEntries.store")
            }
        }()
        let configuration = ModelConfiguration(url: storeURL)

        do {
            self.container = try ModelContainer(
                for: StepsEntity.self,
                configurations: configuration
            )
        } catch {
            // If the on-disk store schema is incompatible (common during active dev),
            // wipe the local store and recreate it to avoid a hard crash.
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(
                for: StepsEntity.self,
                configurations: configuration
            )
        }
    }

    // MARK: CREATE
    func createStepsEntry(steps: StepsModel) throws {
        let entity = StepsEntity(from: steps)
        mainContext.insert(entity)
        try mainContext.save()
    }

    // MARK: READ
    func readStepsEntry(id: String) throws -> StepsModel {
        let descriptor = FetchDescriptor<StepsEntity>(
            predicate: #Predicate<StepsEntity> { $0.id == id }
        )

        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        return entity.toModel()
    }

    func readAllLocalStepsEntries() throws -> [StepsModel] {
        let descriptor = FetchDescriptor<StepsEntity>(
            sortBy: [SortDescriptor(\StepsEntity.dateCreated, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    // MARK: UPDATE
    func updateStepsEntry(steps: StepsModel) throws {
        let entryId = steps.id
        let descriptor = FetchDescriptor<StepsEntity>(predicate: #Predicate<StepsEntity> { $0.id == entryId })
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }

        entity.number = steps.number
        entity.dateModified = Date.now
        
        try mainContext.save()
    }

    // MARK: DELETE
    func deleteStepsEntry(id: String) throws {
        let descriptor = FetchDescriptor<StepsEntity>(predicate: #Predicate<StepsEntity> { $0.id == id })
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }

    func deleteAllLocalStepsEntries() throws {
        let descriptor = FetchDescriptor<StepsEntity>()
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }
}
