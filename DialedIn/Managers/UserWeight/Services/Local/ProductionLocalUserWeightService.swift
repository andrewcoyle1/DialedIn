//
//  ProductionLocalUserWeightService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftData

struct SwiftLocalUserWeightService: LocalUserWeightService {
    
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }

    init() {
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.WeightEntriesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("WeightEntries.store")
            } else {
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.WeightEntriesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("WeightEntries.store")
            }
        }()
        let configuration = ModelConfiguration(url: storeURL)

        do {
            self.container = try ModelContainer(
                for: WeightEntryEntity.self,
                configurations: configuration
            )
        } catch {
            // If the on-disk store schema is incompatible (common during active dev),
            // wipe the local store and recreate it to avoid a hard crash.
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(
                for: WeightEntryEntity.self,
                configurations: configuration
            )
        }
    }
    
    // MARK: CREATE
    func createWeightEntry(weightEntry: WeightEntry) throws {
        let entity = WeightEntryEntity(from: weightEntry)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    // MARK: READ
    func readWeightEntry(id: String) throws -> WeightEntry {
        let descriptor = FetchDescriptor<WeightEntryEntity>(
            predicate: #Predicate<WeightEntryEntity> { $0.id == id }
        )
        
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        return entity.toModel()
    }

    func readWeightEntries() throws -> [WeightEntry] {
        let descriptor = FetchDescriptor<WeightEntryEntity>(
            sortBy: [SortDescriptor(\WeightEntryEntity.dateCreated, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }

    }
        
    // MARK: UPDATE
    func updateWeightEntry(entry: WeightEntry) throws {
        let entryId = entry.id
        let descriptor = FetchDescriptor<WeightEntryEntity>(predicate: #Predicate<WeightEntryEntity> { $0.id == entryId })
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        
        entity.authorId = entry.authorId
        entity.weightKg = entry.weightKg
        entity.bodyFatPercentage = entry.bodyFatPercentage
        entity.date = entry.date
        entity.source = entry.source
        entity.notes = entry.notes
        entity.dateCreated = entry.dateCreated
        entity.healthKitUUID = entry.healthKitUUID
        
        try mainContext.save()
    }

    // MARK: DELETE
    
    func deleteWeightEntry(id: String) throws {
        let descriptor = FetchDescriptor<WeightEntryEntity>(predicate: #Predicate<WeightEntryEntity> { $0.id == id })
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }
}
