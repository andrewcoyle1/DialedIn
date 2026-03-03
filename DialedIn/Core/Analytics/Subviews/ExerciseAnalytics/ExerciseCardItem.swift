//
//  ExerciseCardItem.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

struct ExerciseCardItem: Identifiable {
    let templateId: String
    let name: String
    /// Last 7 workouts including this exercise: (date, best 1-RM in that workout).
    let sparklineData: [(date: Date, value: Double)]
    let latest1RM: Double

    var id: String { templateId }
}
