//
//  WeightEntry.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct WeightEntry: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let weightKg: Double
    let date: Date
    let source: WeightSource
    let notes: String?
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        weightKg: Double,
        date: Date,
        source: WeightSource = .manual,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.weightKg = weightKg
        self.date = date
        self.source = source
        self.notes = notes
        self.createdAt = createdAt
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weightKg = "weight_kg"
        case date
        case source
        case notes
        case createdAt = "created_at"
    }
}

// MARK: - Mock Data
extension WeightEntry {
    static func mock(weightKg: Double, daysAgo: Int = 0) -> WeightEntry {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return WeightEntry(
            userId: "mockUser",
            weightKg: weightKg,
            date: date,
            source: .manual
        )
    }
    
    static var mocks: [WeightEntry] {
        [
            mock(weightKg: 72.0, daysAgo: 0),
            mock(weightKg: 72.3, daysAgo: 7),
            mock(weightKg: 72.8, daysAgo: 14),
            mock(weightKg: 73.2, daysAgo: 21),
            mock(weightKg: 73.5, daysAgo: 28)
        ]
    }
}
