//
//  GymProfileEntitySync.swift
//  DialedIn
//
//  Created by AI on 21/01/2026.
//

import Foundation

struct SyncEntitiesConfig<Model, Entity> {
    var modelId: (Model) -> String
    var entityId: (Entity) -> String
    var update: (Entity, Model) -> Void
    var create: (Model) -> Entity
}

func syncEntities<Model, Entity>(
    existing: [Entity],
    models: [Model],
    config: SyncEntitiesConfig<Model, Entity>
) -> [Entity] {
    let existingById = Dictionary(uniqueKeysWithValues: existing.map { (config.entityId($0), $0) })
    var result: [Entity] = []
    result.reserveCapacity(models.count)
    for model in models {
        let id = config.modelId(model)
        if let entity = existingById[id] {
            config.update(entity, model)
            result.append(entity)
        } else {
            result.append(config.create(model))
        }
    }
    return result
}
