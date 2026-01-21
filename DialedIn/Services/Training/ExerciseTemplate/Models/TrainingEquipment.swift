//
//  TrainingEquipment.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct FreeWeights: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var range: [FreeWeightsAvailable]
    
    var isActive: Bool
}

struct FreeWeightsAvailable: Identifiable, Codable {
    var id: String
    
    var plateColour: String?
    var availableWeights: Double
    var unit: ExerciseWeightUnit
    
    var isActive: Bool
}

struct LoadableBars: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultBaseWeight: LoadableBarsBaseWeight
    var baseWeights: [LoadableBarsBaseWeight]
    
    var isActive: Bool
}

struct LoadableBarsBaseWeight: Identifiable, Codable {
    var id: String
    
    var baseWeight: Double
    
    var unit: ExerciseWeightUnit
    
    var isActive: Bool
}

struct SupportEquipment: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    
    var isActive: Bool
}

struct CableMachine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultRange: CableMachineRange
    var ranges: [CableMachineRange]
    
    var isActive: Bool
}

struct CableMachineRange: Identifiable, Codable {
    var id: String
    
    var minWeight: Double
    var maxWeight: Double
    var increment: Double
    
    var unit: ExerciseWeightUnit

    var isActive: Bool
}

struct PinLoadedMachine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultRange: PinLoadedMachineRange
    var ranges: [PinLoadedMachineRange]
    
    var isActive: Bool
}

struct PinLoadedMachineRange: Identifiable, Codable {
    var id: String
    
    var minWeight: Double
    var maxWeight: Double
    var increment: Double
    
    var unit: ExerciseWeightUnit

    var isActive: Bool
}

struct PlateLoadedMachine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultBaseWeight: PlateLoadedMachineRange
    var baseWeights: [PlateLoadedMachineRange]
    
    var isActive: Bool
}

struct PlateLoadedMachineRange: Identifiable, Codable {
    var id: String
    
    var baseWeight: Double
    var unit: ExerciseWeightUnit

    var isActive: Bool
}
