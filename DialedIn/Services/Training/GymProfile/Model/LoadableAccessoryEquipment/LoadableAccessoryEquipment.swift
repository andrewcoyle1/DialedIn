//
//  LoadableAccessoryEquipment.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

struct LoadableAccessoryEquipment: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultBaseWeightId: String?
    var baseWeights: [LoadableAccessoryEquipmentRange]
    
    var defaultBaseWeight: LoadableAccessoryEquipmentRange? {
        baseWeights.first(where: { $0.id == self.defaultBaseWeightId })
    }
    
    var isActive: Bool
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        defaultBaseWeightId: String?,
        baseWeights: [LoadableAccessoryEquipmentRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultBaseWeightId = defaultBaseWeightId
        self.baseWeights = baseWeights
        self.isActive = isActive
    }
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        baseWeights: [LoadableAccessoryEquipmentRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultBaseWeightId = baseWeights.first?.id
        self.baseWeights = baseWeights
        self.isActive = isActive
    }
    
    static var defaultLoadableAccessoryEquipment: [LoadableAccessoryEquipment] = [
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Fat Grip Attachments",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: false
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Head Harness",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Loadable Dip/Pull-Up Belt",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: false
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Wrist Roller",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
    
    static var mock: LoadableAccessoryEquipment {
        mocks[0]
    }
    
    static var mocks: [LoadableAccessoryEquipment] = [
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Fat Grip Attachments",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: false
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Head Harness",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Loadable Dip/Pull-Up Belt",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: false
        ),
        LoadableAccessoryEquipment(
            id: UUID().uuidString,
            name: "Wrist Roller",
            description: nil,
            baseWeights: [
                LoadableAccessoryEquipmentRange(
                    id: UUID().uuidString,
                    baseWeight: 0,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
}

struct LoadableAccessoryEquipmentRange: Identifiable, Codable {
    var id: String
    
    var baseWeight: Double
    var unit: ExerciseWeightUnit

    var isActive: Bool
}
