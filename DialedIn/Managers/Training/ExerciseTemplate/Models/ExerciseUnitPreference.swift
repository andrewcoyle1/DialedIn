//
//  ExerciseUnitPreference.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/10/2025.
//

import Foundation

enum ExerciseWeightUnit: String, Codable, CaseIterable {
    case kilograms
    case pounds
    
    var abbreviation: String {
        switch self {
        case .kilograms: return "kg"
        case .pounds: return "lbs"
        }
    }
    
    var displayName: String {
        switch self {
        case .kilograms: return "Kilograms"
        case .pounds: return "Pounds"
        }
    }
}

enum ExerciseDistanceUnit: String, Codable, CaseIterable {
    case meters
    case miles
    
    var abbreviation: String {
        switch self {
        case .meters: return "m"
        case .miles: return "mi"
        }
    }
    
    var displayName: String {
        switch self {
        case .meters: return "Meters"
        case .miles: return "Miles"
        }
    }
}

struct ExerciseUnitPreference: Codable {
    let exerciseTemplateId: String
    var weightUnit: ExerciseWeightUnit
    var distanceUnit: ExerciseDistanceUnit
    
    init(exerciseTemplateId: String, weightUnit: ExerciseWeightUnit = .kilograms, distanceUnit: ExerciseDistanceUnit = .meters) {
        self.exerciseTemplateId = exerciseTemplateId
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
    }
}
