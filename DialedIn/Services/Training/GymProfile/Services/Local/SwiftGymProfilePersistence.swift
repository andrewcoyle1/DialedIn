//
//  SwiftGymProfilePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftGymProfilePersistence: LocalGymProfilePersistence {

    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        let storeURL: URL = {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                let libraryURL = groupURL.appendingPathComponent("Library", isDirectory: true)
                let appSupportURL = libraryURL.appendingPathComponent("Application Support", isDirectory: true)
                let directory = appSupportURL.appendingPathComponent("DialedIn.GymProfilesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("GymProfiles.store")
            } else {
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let directory = appSupport.appendingPathComponent("DialedIn.GymProfilesStore", isDirectory: true)
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                return directory.appendingPathComponent("GymProfiles.store")
            }
        }()
        let configuration = ModelConfiguration(url: storeURL)
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(
            for: GymProfileEntity.self,
            FreeWeightEntity.self,
            FreeWeightAvailableEntity.self,
            LoadableBarEntity.self,
            LoadableBarBaseWeightEntity.self,
            FixedWeightBarEntity.self,
            FixedWeightBarBaseWeightEntity.self,
            BandsEntity.self,
            BandsAvailableEntity.self,
            BodyWeightEntity.self,
            BodyWeightAvailableEntity.self,
            SupportEquipmentEntity.self,
            AccessoryEquipmentEntity.self,
            LoadableAccessoryEquipmentEntity.self,
            LoadableAccessoryEquipmentRangeEntity.self,
            CableMachineEntity.self,
            CableMachineRangeEntity.self,
            PlateLoadedMachineEntity.self,
            PlateLoadedMachineRangeEntity.self,
            PinLoadedMachineEntity.self,
            PinLoadedMachineRangeEntity.self,
            configurations: configuration
        )
    }
        
    // MARK: CREATE
    func createGymProfile(profile: GymProfileModel) throws {
        let entity = GymProfileEntity(from: profile)
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    // MARK: READ
    func readGymProfile(profileId: String) throws -> GymProfileModel {
        
        let descriptor = FetchDescriptor<GymProfileEntity>(
            predicate: #Predicate<GymProfileEntity> { $0.id == profileId }
        )
        
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }
        return entity.toModel()
    }
    
    func readAllLocalGymProfiles(includeDeleted: Bool) throws -> [GymProfileModel] {
        let descriptor: FetchDescriptor<GymProfileEntity>
        if includeDeleted {
            descriptor = FetchDescriptor<GymProfileEntity>(
                sortBy: [SortDescriptor(\GymProfileEntity.dateCreated, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<GymProfileEntity>(
                predicate: #Predicate<GymProfileEntity> { $0.deletedAt == nil },
                sortBy: [SortDescriptor(\GymProfileEntity.dateCreated, order: .reverse)]
            )
        }
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
    // MARK: UPDATE
    func updateGymProfile(profile: GymProfileModel) throws {
        let profileId = profile.id
        let descriptor = FetchDescriptor<GymProfileEntity>(predicate: #Predicate<GymProfileEntity> { $0.id == profileId })
        guard let entity = try mainContext.fetch(descriptor).first else {
            throw URLError(.fileDoesNotExist)
        }

        entity.update(from: profile)

        try mainContext.save()

    }
    
    // MARK: DELETE
    func deleteGymProfile(profile: GymProfileModel) throws {
        let profileId = profile.id
        let descriptor = FetchDescriptor<GymProfileEntity>(predicate: #Predicate<GymProfileEntity> { $0.id == profileId })
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            entity.deletedAt = profile.deletedAt ?? .now
            entity.dateModified = profile.dateModified
        }
        if !entities.isEmpty {
            try mainContext.save()
        }
    }
}
