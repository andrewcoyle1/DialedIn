//
//  HealthKitManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
@testable import DialedIn

#if canImport(HealthKit) && !targetEnvironment(macCatalyst)
import HealthKit

/// `HealthKitManager` is a thin pass-through to `HealthService`, so these pin the two things it
/// actually does on top of the service: start `isAuthorized` false regardless of what the service
/// would report, and propagate a `requestAuthorisation()` failure rather than swallowing it.
@MainActor
struct HealthKitManagerTests {

    @Test("Test A New Manager Is Not Authorized Even When The Service Can Request It")
    func testANewManagerIsNotAuthorizedEvenWhenTheServiceCanRequestIt() {
        let manager = HealthKitManager(service: MockHealthService(canRequestAuthorisation: true))

        #expect(manager.isAuthorized == false)
    }

    @Test("Test Can Request Authorisation Reflects The Service")
    func testCanRequestAuthorisationReflectsTheService() {
        #expect(HealthKitManager(service: MockHealthService(canRequestAuthorisation: true)).canRequestAuthorisation())
        #expect(HealthKitManager(service: MockHealthService(canRequestAuthorisation: false)).canRequestAuthorisation() == false)
    }

    @Test("Test Requesting Authorisation Succeeds When The Service Does")
    func testRequestingAuthorisationSucceedsWhenTheServiceDoes() async throws {
        let manager = HealthKitManager(service: MockHealthService(showError: false))

        try await manager.requestAuthorisation()
    }

    @Test("Test Requesting Authorisation Propagates The Service's Failure")
    func testRequestingAuthorisationPropagatesTheServicesFailure() async {
        let manager = HealthKitManager(service: MockHealthService(showError: true))

        await #expect(throws: (any Error).self) {
            try await manager.requestAuthorisation()
        }
    }

    @Test("Test Needs Authorisation For Required Types Reflects The Service")
    func testNeedsAuthorisationForRequiredTypesReflectsTheService() {
        let manager = HealthKitManager(service: MockHealthService())

        #expect(manager.needsAuthorisationForRequiredTypes())
    }

    @Test("Test Get Health Store Routes Through The Service Rather Than A Stored Constant")
    func testGetHealthStoreRoutesThroughTheServiceRatherThanAStoredConstant() {
        // `MockHealthService.getHealthStore()` hands back a fresh `HKHealthStore` on every call.
        // If `HealthKitManager.getHealthStore()` returned its own cached `healthStore` instead of
        // calling through, this would still pass — the point is that it doesn't crash routing to
        // the service on every call, matching what `init` did to populate `healthStore` itself.
        let manager = HealthKitManager(service: MockHealthService())

        let first = manager.getHealthStore()
        let second = manager.getHealthStore()

        #expect(type(of: first) == HKHealthStore.self)
        #expect(type(of: second) == HKHealthStore.self)
    }
}

#endif
