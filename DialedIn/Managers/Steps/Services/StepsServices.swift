//
//  StepsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

@MainActor
protocol StepsServices {
    
    var remote: RemoteStepsService { get }
    var local: LocalStepsPersistence { get }
    #if canImport(HealthKit)
    var healthKit: HealthKitStepsService? { get }
    #endif

}
