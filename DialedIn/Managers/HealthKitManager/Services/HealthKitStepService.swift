//
//  HealthKitStepService.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

struct DailyStepCount: Equatable {
    let date: Date
    let steps: Int
}

enum HealthKitStepServiceError: Error {
    case healthDataUnavailable
}

protocol HealthKitStepService {
    func readDailyStepCounts(from startDate: Date, to endDate: Date) async throws -> [DailyStepCount]
}
