//
//  ProductionBodyMeasurementServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionBodyMeasurementServices: BodyMeasurementServices {
    let remote: RemoteBodyMeasurementService = ProductionRemoteBodyMeasurementService()
    let local: LocalBodyMeasurementService = SwiftLocalBodyMeasurementService()
#if canImport(HealthKit)
    let healthKit: HealthKitWeightService? = ProductionHealthKitWeightService()
#endif
}
