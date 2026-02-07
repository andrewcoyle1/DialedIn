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
    let last7DaysData: [Double]
    let latest1RM: Double

    var id: String { templateId }
}
