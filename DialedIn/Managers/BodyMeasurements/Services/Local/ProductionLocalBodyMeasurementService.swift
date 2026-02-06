//
//  ProductionLocalBodyMeasurementService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftData

struct SwiftLocalBodyMeasurementService: LocalBodyMeasurementService {

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
                for: BodyMeasurementEntryEntity.self,
                configurations: configuration
            )
        } catch {
            // If the on-disk store schema is incompatible (common during active dev),
            // wipe the local store and recreate it to avoid a hard crash.
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
            // swiftlint:disable:next force_try
            self.container = try! ModelContainer(
                for: BodyMeasurementEntryEntity.self,
                configurations: configuration
            )
        }
    }

    // MARK: CREATE
    func createWeightEntry(weightEntry: BodyMeasurementEntry) throws {
        let entity = BodyMeasurementEntryEntity(from: weightEntry)
        mainContext.insert(entity)
        try mainContext.save()
    }

    // MARK: READ
    func readWeightEntry(id: String) throws -> BodyMeasurementEntry {
        let descriptor = FetchDescriptor<BodyMeasurementEntryEntity>(
            predicate: #Predicate<BodyMeasurementEntryEntity> { $0.id == id }
        )

        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        return entity.toModel()
    }

    func readWeightEntries() throws -> [BodyMeasurementEntry] {
        let descriptor = FetchDescriptor<BodyMeasurementEntryEntity>(
            sortBy: [SortDescriptor(\BodyMeasurementEntryEntity.dateCreated, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }

    // MARK: UPDATE
    func updateWeightEntry(entry: BodyMeasurementEntry) throws {
        let entryId = entry.id
        let descriptor = FetchDescriptor<BodyMeasurementEntryEntity>(predicate: #Predicate<BodyMeasurementEntryEntity> { $0.id == entryId })
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }

        entity.authorId = entry.authorId
        entity.weightKg = entry.weightKg
        entity.bodyFatPercentage = entry.bodyFatPercentage
        entity.neckCircumference = entry.neckCircumference
        entity.shoulderCircumference = entry.shoulderCircumference
        entity.bustCircumference = entry.bustCircumference
        entity.chestCircumference = entry.chestCircumference
        entity.waistCircumference = entry.waistCircumference
        entity.hipCircumference = entry.hipCircumference
        entity.leftBicepCircumference = entry.leftBicepCircumference
        entity.rightBicepCircumference = entry.rightBicepCircumference
        entity.leftForearmCircumference = entry.leftForearmCircumference
        entity.rightForearmCircumference = entry.rightForearmCircumference
        entity.leftWristCircumference = entry.leftWristCircumference
        entity.rightWristCircumference = entry.rightWristCircumference
        entity.leftThighCircumference = entry.leftThighCircumference
        entity.rightThighCircumference = entry.rightThighCircumference
        entity.leftCalfCircumference = entry.leftCalfCircumference
        entity.rightCalfCircumference = entry.rightCalfCircumference
        entity.leftAnkleCircumference = entry.leftAnkleCircumference
        entity.rightAnkleCircumference = entry.rightAnkleCircumference
        entity.progressPhotoURLs = entry.progressPhotoURLs
        entity.date = entry.date
        entity.source = entry.source
        entity.notes = entry.notes
        entity.dateCreated = entry.dateCreated
        entity.healthKitUUID = entry.healthKitUUID

        try mainContext.save()
    }

    // MARK: DELETE
    func deleteWeightEntry(id: String) throws {
        let descriptor = FetchDescriptor<BodyMeasurementEntryEntity>(predicate: #Predicate<BodyMeasurementEntryEntity> { $0.id == id })
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }
}
