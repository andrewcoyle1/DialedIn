#if canImport(HealthKit)
import Foundation

final class MockHealthKitStepsService: HealthKitStepsService {
    private(set) var samples: [HealthKitStepsSample]

    init(samples: [HealthKitStepsSample] = []) {
        self.samples = samples
    }

    func readStepsSamples(since: Date?, earliestDate: Date?) async throws -> [HealthKitStepsSample] {
        var filtered = samples
        if let since {
            filtered = filtered.filter { $0.date > since }
        }
        if let earliestDate {
            filtered = filtered.filter { $0.date >= earliestDate }
        }
        return filtered
    }

    func saveStepsSample(steps: Int, date: Date) async throws -> String {
        let sample = HealthKitStepsSample(id: UUID().uuidString, steps: steps, date: date)
        samples.append(sample)
        return sample.id
    }
}
#endif
