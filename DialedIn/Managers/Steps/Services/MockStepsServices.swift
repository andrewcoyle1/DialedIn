//
//  MockStepsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

struct MockStepsServices: StepsServices {
    let local: LocalStepsPersistence
    let remote: RemoteStepsService
#if canImport(HealthKit)
    let healthKit: HealthKitStepsService?
#endif

    init(delay: Double = 0, showError: Bool = false, hasData: Bool = true) {
        self.remote = MockStepsService(delay: delay, showError: showError)
        self.local = MockStepsPersistence(delay: delay, showError: showError, hasData: hasData)
#if canImport(HealthKit)
        self.healthKit = MockHealthKitStepsService()
#endif

    }
}
