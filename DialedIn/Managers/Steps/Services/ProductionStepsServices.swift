//
//  ProductionStepsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

struct ProductionStepsServices: StepsServices {
    let remote: RemoteStepsService = FirebaseStepsService()
    let local: LocalStepsPersistence = SwiftStepsPersistence()
#if canImport(HealthKit)
    let healthKit: HealthKitStepsService? = ProductionHealthKitStepsService()
#endif
}
