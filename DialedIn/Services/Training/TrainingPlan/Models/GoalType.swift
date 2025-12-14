//
//  GoalType.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/12/2025.
//

import Foundation

enum GoalType: String, Codable, CaseIterable {
    case strength // Lift X kg on an exercise
    case volume // Total volume lifted
    case consistency // Workouts completed
    case frequency // Workouts per week
    case bodyweight // Target bodyweight
    
    var description: String {
        switch self {
        case .strength:
            return "Strength Goal"
        case .volume:
            return "Volume Goal"
        case .consistency:
            return "Consistency Goal"
        case .frequency:
            return "Frequency Goal"
        case .bodyweight:
            return "Bodyweight Goal"
        }
    }
    
    var unit: String {
        switch self {
        case .strength:
            return "kg"
        case .volume:
            return "kg"
        case .consistency:
            return "workouts"
        case .frequency:
            return "per week"
        case .bodyweight:
            return "kg"
        }
    }
}
