//
//  HealthKitManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import Foundation
import SwiftUI
import os
#if canImport(HealthKit)
import HealthKit

@Observable
@MainActor
class HealthKitManager: NSObject {
    
    private let service: HealthService
    let healthStore: HKHealthStore
    var isAuthorized: Bool
    
    init(service: HealthService = HealthKitService()) {
        self.service = service
        self.healthStore = service.getHealthStore()
        self.isAuthorized = false
    }
    
    func canRequestAuthorisation() -> Bool {
        service.canRequestAuthorisation()
    }
    
    func requestAuthorization() async throws {
        try await service.requestAuthorisation()
    }
    
    /// Returns true when we should present the HealthKit permissions screen
    /// for our required types (represents whether user has not yet granted or has denied access).
    /// Uses `HKQuantityType(.bodyMass)` as the representative write-permission type
    /// since read authorization status cannot be queried.
    func needsAuthorisationForRequiredTypes() -> Bool {
        service.needsAuthorisationForRequiredTypes()
    }
    
    func getHealthStore() -> HKHealthStore {
        service.getHealthStore()
    }
}
#endif
