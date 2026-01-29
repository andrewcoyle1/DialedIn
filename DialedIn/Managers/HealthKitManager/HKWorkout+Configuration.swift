import Foundation

#if canImport(HealthKit)
import HealthKit

extension HKWorkout {
	var workoutConfiguration: HKWorkoutConfiguration {
		let configuration = HKWorkoutConfiguration()
		configuration.activityType = workoutActivityType
		if let isIndoorWorkout = self.metadata![HKMetadataKeyIndoorWorkout] as? Bool,
			isIndoorWorkout {
				configuration.locationType = .indoor
		} else {
				configuration.locationType = .outdoor
		}
		return configuration
	}
}
#endif
