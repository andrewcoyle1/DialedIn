//
//  HealthService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

#if canImport(HealthKit)
import HealthKit
protocol HealthService {
    func canRequestAuthorisation() -> Bool
    func requestAuthorisation() async throws
    func needsAuthorisationForRequiredTypes() -> Bool
    func getHealthStore() -> HKHealthStore
}
#endif
