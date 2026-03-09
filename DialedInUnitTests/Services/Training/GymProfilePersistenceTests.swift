//
//  GymProfilePersistenceTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI
import SwiftData
import Testing
@testable import DialedIn

@MainActor
struct GymProfilePersistenceTests {

    @Test("Gym profile updates preserve child entity identity")
    @MainActor
    func testUpdatePreservesChildEntityIdentity() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: GymProfileEntity.self,
            FreeWeightEntity.self,
            FreeWeightAvailableEntity.self,
            LoadableBarEntity.self,
            LoadableBarBaseWeightEntity.self,
            SupportEquipmentEntity.self,
            CableMachineEntity.self,
            CableMachineRangeEntity.self,
            PlateLoadedMachineEntity.self,
            PinLoadedMachineEntity.self,
            PinLoadedMachineRangeEntity.self,
            configurations: configuration
        )
        let context = container.mainContext
        let profile = makeMinimalProfile()
        let entity = GymProfileEntity(from: profile)
        context.insert(entity)
        try context.save()

        let freeWeightPersistentID = entity.freeWeights[0].persistentModelID
        let freeWeightRangePersistentID = entity.freeWeights[0].range[0].persistentModelID
        let loadableBarPersistentID = entity.loadableBars[0].persistentModelID
        let loadableBarBasePersistentID = entity.loadableBars[0].baseWeights[0].persistentModelID

        var updated = profile
        updated.name = "Updated Gym"
        updated.dateModified = Date(timeIntervalSince1970: 200)
        updated.freeWeights[0].isActive = false

        entity.update(from: updated)
        try context.save()

        let descriptor = FetchDescriptor<GymProfileEntity>(predicate: #Predicate<GymProfileEntity> { $0.id == profile.id })
        let fetched = try context.fetch(descriptor).first!
        let fetchedFreeWeight = fetched.freeWeights.first { $0.id == profile.freeWeights[0].id }!
        let fetchedFreeWeightRange = fetchedFreeWeight.range.first { $0.id == profile.freeWeights[0].range[0].id }!
        let fetchedLoadableBar = fetched.loadableBars.first { $0.id == profile.loadableBars[0].id }!
        let fetchedLoadableBarBase = fetchedLoadableBar.baseWeights.first { $0.id == profile.loadableBars[0].baseWeights[0].id }!

        #expect(fetchedFreeWeight.persistentModelID == freeWeightPersistentID)
        #expect(fetchedFreeWeightRange.persistentModelID == freeWeightRangePersistentID)
        #expect(fetchedLoadableBar.persistentModelID == loadableBarPersistentID)
        #expect(fetchedLoadableBarBase.persistentModelID == loadableBarBasePersistentID)
    }
}

private func makeMinimalProfile() -> GymProfileModel {
    GymProfileModel(
        id: "gym-profile-1",
        authorId: "author-1",
        name: "Original Gym",
        icon: "dumbbell",
        dateCreated: Date(timeIntervalSince1970: 100),
        dateModified: Date(timeIntervalSince1970: 100),
        deletedAt: nil,
        freeWeights: makeMinimalFreeWeights(),
        loadableBars: makeMinimalLoadableBars(),
        supportEquipment: makeMinimalSupportEquipment(),
        cableMachines: makeMinimalCableMachines(),
        plateLoadedMachines: makeMinimalPlateLoadedMachines(),
        pinLoadedMachines: makeMinimalPinLoadedMachines()
    )
}

private func makeMinimalFreeWeights() -> [FreeWeights] {
    [
        FreeWeights(
            id: "free-weight-1",
            name: "Dumbbells",
            description: nil,
            needsColour: true,
            range: [
                FreeWeightsAvailable(
                    id: "free-weight-range-1",
                    plateColour: Color.red.asHex(),
                    availableWeights: 10,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
}

private func makeMinimalLoadableBars() -> [LoadableBars] {
    [
        LoadableBars(
            id: "loadable-bar-1",
            name: "Barbell",
            description: nil,
            baseWeights: [
                LoadableBarsBaseWeight(
                    id: "loadable-bar-base-1",
                    baseWeight: 20,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
}

private func makeMinimalSupportEquipment() -> [SupportEquipment] {
    [
        SupportEquipment(
            id: "support-1",
            name: "Bench",
            description: nil,
            isActive: true
        )
    ]
}

private func makeMinimalCableMachines() -> [CableMachine] {
    [
        CableMachine(
            id: "cable-1",
            name: "Cable Machine",
            description: nil,
            ranges: [
                CableMachineRange(
                    id: "cable-range-1",
                    name: "Default Range",
                    minWeight: 0,
                    maxWeight: 100,
                    increment: 5,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
}

private func makeMinimalPlateLoadedMachines() -> [PlateLoadedMachine] {
    [
        PlateLoadedMachine(
            id: "plate-1",
            name: "Plate Machine",
            description: nil,
            baseWeight: 40,
            unit: .kilograms,
            isActive: true
        )
    ]
}

private func makeMinimalPinLoadedMachines() -> [PinLoadedMachine] {
    [
        PinLoadedMachine(
            id: "pin-1",
            name: "Pin Machine",
            description: nil,
            ranges: [
                PinLoadedMachineRange(
                    id: "pin-range-1",
                    name: "Default Range",
                    minWeight: 0,
                    maxWeight: 100,
                    increment: 5,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        )
    ]
}
