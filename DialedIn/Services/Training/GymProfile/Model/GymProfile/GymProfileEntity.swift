//
//  GymProfileEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData

@Model
class GymProfileEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    var name: String
    var imageUrl: String?
    var icon: String
    var dateCreated: Date
    var dateModified: Date
    var deletedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \FreeWeightEntity.gymProfile) var freeWeights: [FreeWeightEntity]
    @Relationship(deleteRule: .cascade, inverse: \LoadableBarEntity.gymProfile) var loadableBars: [LoadableBarEntity]
    @Relationship(deleteRule: .cascade, inverse: \FixedWeightBarEntity.gymProfile) var fixedWeightBars: [FixedWeightBarEntity]
    @Relationship(deleteRule: .cascade, inverse: \BandsEntity.gymProfile) var bands: [BandsEntity]
    @Relationship(deleteRule: .cascade, inverse: \BodyWeightEntity.gymProfile) var bodyWeights: [BodyWeightEntity]
    @Relationship(deleteRule: .cascade, inverse: \SupportEquipmentEntity.gymProfile) var supportEquipment: [SupportEquipmentEntity]
    @Relationship(deleteRule: .cascade, inverse: \AccessoryEquipmentEntity.gymProfile) var accessoryEquipment: [AccessoryEquipmentEntity]
    @Relationship(deleteRule: .cascade, inverse: \CableMachineEntity.gymProfile) var cableMachines: [CableMachineEntity]
    @Relationship(deleteRule: .cascade, inverse: \PlateLoadedMachineEntity.gymProfile) var plateLoadedMachines: [PlateLoadedMachineEntity]
    @Relationship(deleteRule: .cascade, inverse: \PinLoadedMachineEntity.gymProfile) var pinLoadedMachines: [PinLoadedMachineEntity]
    
    init(from model: GymProfileModel) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.imageUrl = model.imageUrl
        self.icon = model.icon
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.deletedAt = model.deletedAt
        self.freeWeights = model.freeWeights.map { FreeWeightEntity(from: $0) }
        self.loadableBars = model.loadableBars.map { LoadableBarEntity(from: $0) }
        self.fixedWeightBars = model.fixedWeightBars.map { FixedWeightBarEntity(from: $0) }
        self.bands = model.bands.map { BandsEntity(from: $0) }
        self.bodyWeights = model.bodyWeights.map { BodyWeightEntity(from: $0) }
        self.supportEquipment = model.supportEquipment.map { SupportEquipmentEntity(from: $0) }
        self.accessoryEquipment = model.accessoryEquipment.map { AccessoryEquipmentEntity(from: $0) }
        self.cableMachines = model.cableMachines.map { CableMachineEntity(from: $0) }
        self.plateLoadedMachines = model.plateLoadedMachines.map { PlateLoadedMachineEntity(from: $0) }
        self.pinLoadedMachines = model.pinLoadedMachines.map { PinLoadedMachineEntity(from: $0) }
    }

    @MainActor
    func update(from model: GymProfileModel) {
        self.id = model.id
        self.authorId = model.authorId
        self.name = model.name
        self.imageUrl = model.imageUrl
        self.icon = model.icon
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.deletedAt = model.deletedAt
        self.freeWeights = syncEntities(
            existing: freeWeights,
            models: model.freeWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { FreeWeightEntity(from: $0) }
        )
        self.loadableBars = syncEntities(
            existing: loadableBars,
            models: model.loadableBars,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { LoadableBarEntity(from: $0) }
        )
        self.fixedWeightBars = syncEntities(
            existing: fixedWeightBars,
            models: model.fixedWeightBars,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { FixedWeightBarEntity(from: $0) }
        )
        self.bands = syncEntities(
            existing: bands,
            models: model.bands,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { BandsEntity(from: $0) }
        )
        self.bodyWeights = syncEntities(
            existing: bodyWeights,
            models: model.bodyWeights,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { BodyWeightEntity(from: $0) }
        )
        self.supportEquipment = syncEntities(
            existing: supportEquipment,
            models: model.supportEquipment,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { SupportEquipmentEntity(from: $0) }
        )
        self.accessoryEquipment = syncEntities(
            existing: accessoryEquipment,
            models: model.accessoryEquipment,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { AccessoryEquipmentEntity(from: $0) }
        )
        self.cableMachines = syncEntities(
            existing: cableMachines,
            models: model.cableMachines,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { CableMachineEntity(from: $0) }
        )
        self.plateLoadedMachines = syncEntities(
            existing: plateLoadedMachines,
            models: model.plateLoadedMachines,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { PlateLoadedMachineEntity(from: $0) }
        )
        self.pinLoadedMachines = syncEntities(
            existing: pinLoadedMachines,
            models: model.pinLoadedMachines,
            modelId: { $0.id },
            entityId: { $0.id },
            update: { $0.update(from: $1) },
            create: { PinLoadedMachineEntity(from: $0) }
        )
    }
    
    @MainActor
    func toModel() -> GymProfileModel {
        GymProfileModel(
            id: self.id,
            authorId: self.authorId,
            name: self.name,
            imageUrl: self.imageUrl,
            icon: self.icon,
            dateCreated: self.dateCreated,
            dateModified: self.dateModified,
            deletedAt: self.deletedAt,
            freeWeights: self.freeWeights.map { $0.toModel() },
            loadableBars: self.loadableBars.map { $0.toModel() },
            fixedWeightBars: self.fixedWeightBars.map { $0.toModel() },
            bands: self.bands.map { $0.toModel() },
            bodyWeights: self.bodyWeights.map { $0.toModel() },
            supportEquipment: self.supportEquipment.map { $0.toModel() },
            accessoryEquipment: self.accessoryEquipment.map { $0.toModel() },
            cableMachines: self.cableMachines.map { $0.toModel() },
            plateLoadedMachines: self.plateLoadedMachines.map { $0.toModel() },
            pinLoadedMachines: self.pinLoadedMachines.map { $0.toModel() }
        )
    }
}
