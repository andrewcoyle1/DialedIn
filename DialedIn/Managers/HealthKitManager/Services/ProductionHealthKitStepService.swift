//
//  ProductionHealthKitStepService.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

#if canImport(HealthKit)
import HealthKit

struct ProductionHealthKitStepService: HealthKitStepService {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }

    func readDailyStepCounts(from startDate: Date, to endDate: Date) async throws -> [DailyStepCount] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitStepServiceError.healthDataUnavailable
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return []
        }

        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: startDate)
        let interval = DateComponents(day: 1)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: nil,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                var dailySteps: [DailyStepCount] = []
                results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    dailySteps.append(DailyStepCount(date: statistics.startDate, steps: Int(steps)))
                }
                continuation.resume(returning: dailySteps.sorted { $0.date < $1.date })
            }

            healthStore.execute(query)
        }
    }
}
#endif
