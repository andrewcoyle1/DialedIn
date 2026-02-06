//
//  MockUserWeightServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockUserWeightServices: UserWeightServices {
    let remote: RemoteUserWeightService
    let local: LocalUserWeightService
#if canImport(HealthKit)
    let healthKit: HealthKitWeightService?
#endif
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteUserWeightService(delay: delay, showError: showError)
        self.local = MockLocalUserWeightService(delay: delay, showError: showError)
#if canImport(HealthKit)
        self.healthKit = MockHealthKitWeightService()
#endif
    }
}
