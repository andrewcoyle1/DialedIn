//
//  StepsSource.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

enum StepsSource: String, Codable {
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
