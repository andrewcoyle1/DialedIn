//
//  WeightSource.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

enum WeightSource: String, Codable {
    case manual
    case healthkit
    case imported
    
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .healthkit: return "HealthKit"
        case .imported: return "Imported"
        }
    }
}
