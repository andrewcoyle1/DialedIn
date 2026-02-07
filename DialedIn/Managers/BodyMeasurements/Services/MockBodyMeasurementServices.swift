//
//  MockBodyMeasurementServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockBodyMeasurementServices: BodyMeasurementServices {
    let remote: RemoteBodyMeasurementService
    let local: LocalBodyMeasurementService
#if canImport(HealthKit)
    let healthKit: HealthKitWeightService?
#endif

    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteBodyMeasurementService(delay: delay, showError: showError)
        self.local = MockLocalBodyMeasurementService(delay: delay, showError: showError)
#if canImport(HealthKit)
        self.healthKit = MockHealthKitWeightService()
#endif
    }
}
