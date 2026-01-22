//
//  GymProfileEntitySync.swift
//  DialedIn
//
//  Created by AI on 21/01/2026.
//

import Foundation

func syncEntities<Model, Entity>(
    existing: [Entity],
    models: [Model],
    modelId: (Model) -> String,
    entityId: (Entity) -> String,
    update: (Entity, Model) -> Void,
    create: (Model) -> Entity
) -> [Entity] {
    let existingById = Dictionary(uniqueKeysWithValues: existing.map { (entityId($0), $0) })
    var result: [Entity] = []
    result.reserveCapacity(models.count)
    for model in models {
        let id = modelId(model)
        if let entity = existingById[id] {
            update(entity, model)
            result.append(entity)
        } else {
            result.append(create(model))
        }
    }
    return result
}
