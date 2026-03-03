//
//  ExerciseType.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/01/2026.
//

enum ExerciseType: String, Equatable, DataSyncModelProtocol, PickableItem {
    
    var id: String { self.rawValue }
    
    case compoundUpper
    case compoundLower
    case isolationUpper
    case isolationLower
    case core
    
    var name: String {
        switch self {
        case .compoundUpper: return "Upper Compound"
        case .compoundLower: return "Lower Compound"
        case .isolationUpper: return "Upper Isolation"
        case .isolationLower: return "Lower Isolation"
        case .core: return "Core"
        }
    }
    
    var description: String? {
        nil
    }
}
