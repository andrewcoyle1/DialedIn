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
class HealthKitManager {

    let healthStore: HKHealthStore
    var isAuthorized: Bool

    // The quantity type to write to the HealthKit store.
    let typesToShare: Set<HKSampleType> = [
        // MARK: Nutrition Data
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        HKQuantityType(.dietaryFatSaturated),
        HKQuantityType(.dietaryFatMonounsaturated),
        HKQuantityType(.dietaryFatPolyunsaturated),
        HKQuantityType(.dietaryIron),
        HKQuantityType(.dietaryZinc),
        HKQuantityType(.dietaryFiber),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietaryWater),
        HKQuantityType(.dietaryBiotin),
        HKQuantityType(.dietaryCopper),
        HKQuantityType(.dietaryFolate),
        HKQuantityType(.dietaryIodine),
        HKQuantityType(.dietaryNiacin),
        HKQuantityType(.dietarySodium),
        HKQuantityType(.dietaryCalcium),
        HKQuantityType(.dietaryThiamin),
        HKQuantityType(.dietaryCaffeine),
        HKQuantityType(.dietaryChloride),
        HKQuantityType(.dietaryChromium),
        HKQuantityType(.dietarySelenium),
        HKQuantityType(.dietaryMagnesium),
        HKQuantityType(.dietaryManganese),
        HKQuantityType(.dietaryPotassium),
        HKQuantityType(.dietaryMolybdenum),
        HKQuantityType(.dietaryPhosphorus),
        HKQuantityType(.dietaryRiboflavin),
        HKQuantityType(.dietaryCholesterol),
        HKQuantityType(.dietaryVitaminA),
        HKQuantityType(.dietaryVitaminC),
        HKQuantityType(.dietaryVitaminD),
        HKQuantityType(.dietaryVitaminE),
        HKQuantityType(.dietaryVitaminK),
        HKQuantityType(.dietaryVitaminB6),
        HKQuantityType(.dietaryVitaminB12),
        HKQuantityType(.dietaryPantothenicAcid),

        // MARK: Body measurement data
        HKQuantityType(.bodyMass),
        HKQuantityType(.bodyFatPercentage),
        HKQuantityType(.bodyMassIndex),
        HKQuantityType(.leanBodyMass),
        HKQuantityType(.height),
        HKQuantityType(.waistCircumference)

    ]

    // The quantity types to read from the HealthKit store.
    let typesToRead: Set<HKObjectType> = [

        // MARK: Nutrition Data
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        HKQuantityType(.dietaryFatSaturated),
        HKQuantityType(.dietaryFatMonounsaturated),
        HKQuantityType(.dietaryFatPolyunsaturated),
        HKQuantityType(.dietaryIron),
        HKQuantityType(.dietaryZinc),
        HKQuantityType(.dietaryFiber),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietaryWater),
        HKQuantityType(.dietaryBiotin),
        HKQuantityType(.dietaryCopper),
        HKQuantityType(.dietaryFolate),
        HKQuantityType(.dietaryIodine),
        HKQuantityType(.dietaryNiacin),
        HKQuantityType(.dietarySodium),
        HKQuantityType(.dietaryCalcium),
        HKQuantityType(.dietaryThiamin),
        HKQuantityType(.dietaryCaffeine),
        HKQuantityType(.dietaryChloride),
        HKQuantityType(.dietaryChromium),
        HKQuantityType(.dietarySelenium),
        HKQuantityType(.dietaryMagnesium),
        HKQuantityType(.dietaryManganese),
        HKQuantityType(.dietaryPotassium),
        HKQuantityType(.dietaryMolybdenum),
        HKQuantityType(.dietaryPhosphorus),
        HKQuantityType(.dietaryRiboflavin),
        HKQuantityType(.dietaryCholesterol),
        HKQuantityType(.dietaryVitaminA),
        HKQuantityType(.dietaryVitaminC),
        HKQuantityType(.dietaryVitaminD),
        HKQuantityType(.dietaryVitaminE),
        HKQuantityType(.dietaryVitaminK),
        HKQuantityType(.dietaryVitaminB6),
        HKQuantityType(.dietaryVitaminB12),
        HKQuantityType(.dietaryPantothenicAcid),

        // MARK: Body measurement data
        HKQuantityType(.bodyMass),
        HKQuantityType(.bodyFatPercentage),
        HKQuantityType(.bodyMassIndex),
        HKQuantityType(.leanBodyMass),
        HKQuantityType(.height),
        HKQuantityType(.waistCircumference)
    ]
    init() {
        self.healthStore = HKHealthStore()
        self.isAuthorized = false
    }

    func canRequestAuthorisation() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard canRequestAuthorisation() else {
            throw NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data not available on this device"])
        }

        try await healthStore.requestAuthorization(toShare: self.typesToShare, read: self.typesToRead)
    }

    /// Returns true when we should present the HealthKit permissions screen
    /// for our required types (represents whether user has not yet granted or has denied access).
    /// Uses `HKQuantityType(.bodyMass)` as the representative write-permission type
    /// since read authorization status cannot be queried.
    func needsAuthorizationForRequiredTypes() -> Bool {
        guard canRequestAuthorisation() else { return false }

        let bodyMassType = HKQuantityType(.bodyMass)
        let status = healthStore.authorizationStatus(for: bodyMassType)
        switch status {
        case .sharingAuthorized:
            return false
        case .notDetermined, .sharingDenied:
            return true
        @unknown default:
            return true
        }
    }

    func getHealthStore() -> HKHealthStore { 
        healthStore 
    }
}
#endif
