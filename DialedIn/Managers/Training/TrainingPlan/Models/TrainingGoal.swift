//
//  TrainingGoal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/12/2025.
//

import Foundation

struct TrainingGoal: Codable, Equatable, Identifiable {
    let id: String
    let type: GoalType
    let targetValue: Double
    var currentValue: Double
    let targetDate: Date?
    let exerciseId: String? // Optional: specific to an exercise
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case targetValue = "target_value"
        case currentValue = "current_value"
        case targetDate = "target_date"
        case exerciseId = "exercise_id"
    }
    
    init(
        id: String = UUID().uuidString,
        type: GoalType,
        targetValue: Double,
        currentValue: Double = 0,
        targetDate: Date? = nil,
        exerciseId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.targetDate = targetDate
        self.exerciseId = exerciseId
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    static var mocks: [TrainingGoal] {
        [
            TrainingGoal(
                type: .strength,
                targetValue: 100,
                currentValue: 85,
                targetDate: Calendar.current.date(byAdding: .month, value: 2, to: .now),
                exerciseId: "1"
            ),
            TrainingGoal(
                type: .volume,
                targetValue: 50000,
                currentValue: 32000,
                targetDate: Calendar.current.date(byAdding: .month, value: 1, to: .now)
            ),
            TrainingGoal(
                type: .consistency,
                targetValue: 24,
                currentValue: 16,
                targetDate: Calendar.current.date(byAdding: .month, value: 2, to: .now)
            )
        ]
    }
}
