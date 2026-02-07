//
//  MockHealthKitStepService.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

struct MockHealthKitStepService: HealthKitStepService {
    func readDailyStepCounts(from startDate: Date, to endDate: Date) async throws -> [DailyStepCount] {
        let calendar = Calendar.current
        var results: [DailyStepCount] = []
        var current = calendar.startOfDay(for: startDate)
        while current <= endDate {
            let steps = (5000...12000).randomElement() ?? 8000
            results.append(DailyStepCount(date: current, steps: steps))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return results.sorted { $0.date < $1.date }
    }
}
