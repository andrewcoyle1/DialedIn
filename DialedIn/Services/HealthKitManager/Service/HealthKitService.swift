//
//  HealthKitService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

#if canImport(HealthKit)
import HealthKit

struct HealthKitService: HealthService {
    
    let healthStore: HKHealthStore = HKHealthStore()
    // The sample types to write to the HealthKit store.
    let typesToShare: Set<HKSampleType> = [
        
        // MARK: Workout
        HKObjectType.workoutType(),
        
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

    // The object types to read from the HealthKit store.
    let typesToRead: Set<HKObjectType> = [
        
        // MARK: Workout
        HKObjectType.activitySummaryType(),
        HKObjectType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.basalEnergyBurned),
        HKQuantityType(.heartRate),

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
    
    func canRequestAuthorisation() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorisation() async throws {
        guard canRequestAuthorisation() else {
            throw NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Health data not available on this device"])
        }

        try await healthStore.requestAuthorization(toShare: self.typesToShare, read: self.typesToRead)
    }
    
    func needsAuthorisationForRequiredTypes() -> Bool {
        guard canRequestAuthorisation() else { return false }

        // Require workout sharing authorization to start HKWorkoutSession
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)
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
