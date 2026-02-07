//
//  BodyMeasurementServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

protocol BodyMeasurementServices {
    var remote: RemoteBodyMeasurementService { get }
    var local: LocalBodyMeasurementService { get }
#if canImport(HealthKit)
    var healthKit: HealthKitWeightService? { get }
#endif
}
