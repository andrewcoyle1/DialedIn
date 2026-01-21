//
//  GymProfileModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI

struct GymProfileModel: Identifiable, Codable {
    
    var id: String
    var name: String
    var icon: String
    
    var freeWeights: [FreeWeights] = Self.defaultFreeWeights
    var loadableBars: [LoadableBars]
    var supportEquipment: [SupportEquipment]
    var cableMachines: [CableMachine]
    var plateLoadedMachines: [PlateLoadedMachine]
    var pinLoadedMachines: [PinLoadedMachine]
    
    static var defaultFreeWeights: [FreeWeights] = [
        FreeWeights(
            id: UUID().uuidString,
            name: "Bumper Plates",
            description: nil,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 15,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 35,
                    unit: .pounds,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 45,
                    unit: .pounds,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 55,
                    unit: .pounds,
                    isActive: true
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: UUID().uuidString,
            name: "Dumbbells",
            description: nil,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 1,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 2,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 3,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 4,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 6,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 6,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 7,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 8,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 9,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 12,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 12.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 14,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 15,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 16,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 17.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 18,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 22,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 22.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 24,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 26,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 27.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 28,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 30,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 32,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 32.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 34,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 36,
                    unit: .kilograms,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 37.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 38,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 40,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 42,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 42.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 44,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 45,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 46,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 47.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 48,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 50,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 57.5,
                    unit: .kilograms,
                    isActive: true
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: UUID().uuidString,
            name: "Weight Plates",
            description: nil,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.green.asHex(),
                    availableWeights: 1.25,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.blue.asHex(),
                    availableWeights: 2.5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.gray.asHex(),
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.gray.asHex(),
                    availableWeights: 5,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.green.asHex(),
                    availableWeights: 10,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.green.asHex(),
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.yellow.asHex(),
                    availableWeights: 15,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.yellow.asHex(),
                    availableWeights: 35,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.blue.asHex(),
                    availableWeights: 20,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.blue.asHex(),
                    availableWeights: 45,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.red.asHex(),
                    availableWeights: 25,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.red.asHex(),
                    availableWeights: 55,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        )
    ]
    
    static var mock: GymProfileModel {
        mocks[0]
    }
    
    static var mocks: [GymProfileModel] {
        [
            GymProfileModel(
                id: "1",
                name: "Platinum Gym Malahide",
                icon: "dumbbell",
                freeWeights: [
                    FreeWeights(
                        id: UUID().uuidString,
                        name: "Bumper Plates",
                        description: nil,
                        range: [
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 10,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 10,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 25,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 15,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 35,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 45,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 25,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 55,
                                unit: .pounds,
                                isActive: false
                            )
                        ],
                        isActive: true
                    ),
                    FreeWeights(
                        id: UUID().uuidString,
                        name: "Dumbbells",
                        description: nil,
                        range: [
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 1,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 2,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 3,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 4,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 6,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 6,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 7,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 8,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 9,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 10,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 12,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 12.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 14,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 15,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 16,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 17.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 18,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 22,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 22.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 24,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 25,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 26,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 27.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 28,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 30,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 32,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 32.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 34,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 36,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 37.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 38,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 40,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 42,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 42.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 44,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 45,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 46,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 47.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 48,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 50,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 57.5,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    FreeWeights(
                        id: UUID().uuidString,
                        name: "Weight Plates",
                        description: nil,
                        range: [
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 1.25,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 2.5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 10,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 5,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 10,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 25,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 15,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 35,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 45,
                                unit: .pounds,
                                isActive: false
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 25,
                                unit: .kilograms,
                                isActive: true
                            ),
                            FreeWeightsAvailable(
                                id: UUID().uuidString,
                                availableWeights: 55,
                                unit: .pounds,
                                isActive: false
                            )
                        ],
                        isActive: true
                    )
                ],
                loadableBars: [
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "Barbell",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "Cambered Bench Bar",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "Cambered Squat Bar",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "EZ Bar",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 9,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 9,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "Swiss Bar",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    LoadableBars(
                        id: UUID().uuidString,
                        name: "Trap Bar",
                        description: nil,
                        defaultBaseWeight:
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            ),
                        baseWeights: [
                            LoadableBarsBaseWeight(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    )
                ],
                supportEquipment: [
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Adjustable Bench",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Captain's Chair",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Decline Bench",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Decline Bench Press Station",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Flat Bench",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Flat Bench Press Station",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Glute Ham Developer",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Hip Thrust Bench",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Incline Bench Press Station",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Multi-Grip Pull-Up Bar",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Nordic Hamstring Curl Bench",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Parallel Bars",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Power Rack",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Preacher Curl Bench",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Roman Chair",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Seal Row Bench",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Seated Bench",
                        description: nil,
                        isActive: true
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Seated Overhead Press Station",
                        description: nil,
                        isActive: false
                    ),
                    SupportEquipment(
                        id: UUID().uuidString,
                        name: "Squat Stand",
                        description: nil,
                        isActive: false
                    )
                ],
                cableMachines: [
                    CableMachine(
                        id: UUID().uuidString,
                        name: "Cable Lat Pulldown Machine",
                        description: nil,
                        defaultRange: CableMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 500,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 250,
                                increment: 5,
                                unit: .kilograms,
                                isActive: false
                            ),
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 500,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    CableMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Dual Cable Machine",
                        description: nil,
                        defaultRange: CableMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 500,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 250,
                                increment: 5,
                                unit: .kilograms,
                                isActive: false
                            ),
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 500,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    CableMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Single Cable Machine",
                        description: nil,
                        defaultRange: CableMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 500,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 250,
                                increment: 5,
                                unit: .kilograms,
                                isActive: false
                            ),
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 500,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    CableMachine(
                        id: UUID().uuidString,
                        name: "Seated Cable Row Machine",
                        description: nil,
                        defaultRange: CableMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 500,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 250,
                                increment: 5,
                                unit: .kilograms,
                                isActive: false
                            ),
                            CableMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 500,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    )
                ],
                plateLoadedMachines: [
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Ab Coaster Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 9,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 9,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Center Pendulum Reverse Hyperextension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Chest-Supported Plate-Loaded Row Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Chest-Supported T-Bar Row Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Hack Squat Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 45.4,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 9,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Kneeling Plate-Loaded Glute Kickback Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lever-Arm Belt Squat Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 20.4,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 20.4,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lying Decline Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lying Plate-Loaded Chest Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lying Plate-Loaded Leg Curl Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pendulum Squat Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 40.8,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 40.8,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Abdominal Crunch Machine (with Chest Pad)",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Assisted Pull-Up/Dip Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Back Extension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Crunch/Back Extension Combo Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Donkey Calf Raise Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Dual Cable Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Hip Thrust Machine (Starting From The Bottom)",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 7,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 7,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Hip Thrust Machine (Starting From The Top)",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 7,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 7,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Leg Extension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Leg Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 53.5,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 53.5,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Low Row Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Overhead Triceps Extension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Preacher Curl Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Preacher Curl/Triceps Extension Combo Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Pulldown Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Pullover Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Shoulder Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Single Cable Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Plate-Loaded Triceps Extension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pulley Belt Squat Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Reclined Plate-Loaded Incline Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Decline Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Calf Raise Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 22.7,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 22.7,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Chest Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Dip Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Hip Abduction Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Hip Abduction/Adduction Combo Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Hip Adduction Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Incline Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Lateral Raise Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Leg Curl Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Plate-Loaded Shrug Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 22.7,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 22.7,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Side-Plate-Loaded Reverse Hyperextension Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 9,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 9,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Sled",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 36.3,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 36.3,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Smith Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 20,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 20,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Calf Raise Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 30.4,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 30.4,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Chest Press Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Finger Curl Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Glute Kickback Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Lateral Raise Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Leg Curl Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 0,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 0,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Plate-Loaded Shrug Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 22.7,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 22.7,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing T-bar Row Machine (Without Chest Support)",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 18,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 18,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PlateLoadedMachine(
                        id: UUID().uuidString,
                        name: "V-Squat Machine",
                        description: nil,
                        defaultBaseWeight: PlateLoadedMachineRange(
                            id: UUID().uuidString,
                            baseWeight: 24.5,
                            unit: .kilograms,
                            isActive: true
                        ),
                        baseWeights: [
                            PlateLoadedMachineRange(
                                id: UUID().uuidString,
                                baseWeight: 24.5,
                                unit: .kilograms,
                                isActive: true
                            )
                        ],
                        isActive: false
                    )
                ],
                pinLoadedMachines: [
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Biceps Curl Machine With Arms At Side",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Chest-Supported Pin-Loaded Row Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Kneeling Lower Trunk Rotation Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Kneeling Pin-Loaded Glute Kickback Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lying Pin-Loaded Chest Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Lying Pin-Loaded Leg Curl Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Multi-Hip Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pec Deck",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Abdominal Crunch Machine (With Chest Pad)",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Abdominal Crunch Machine (With Front Handles)",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Abdominal Crunch Machine (With Overhead Handles)",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Assisted Pull-Up/Dip Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Back Extension Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Chest Fly Machine With Arm Pads",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Dip Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Hip Thrust Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Leg Extension Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Leg Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Overhead Triceps Extension Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Preacher Curl Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Preacher Curl/Triceps Extension Combo Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Pulldown Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Pullover Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Reverse Hyperextension Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Row Machine (Without Chest Support)",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Shoulder Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Pin-Loaded Tricep Extension Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Reclined Pin-Loaded Incline Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Lower Trunk Rotation Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Calf Raise Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Chest Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Hip Abduction Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Hip Abduction/Adduction Combo Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin Loaded Hip Adduction Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Incline Press Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Lateral Raise Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin-Loaded Leg Curl Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: true
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Seated Pin Loaded Shrug Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Pin-Loaded Calf Raise Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Pin-Loaded Glute Kickback Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Pin-Loaded Lateral Raise Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Standing Pin-Loaded Leg Curl Machine",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Upper Trunk Rotation Machine With Arm Or Shoulder Pads",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    ),
                    PinLoadedMachine(
                        id: UUID().uuidString,
                        name: "Upper Trunk Rotation Machine With Chest Pad",
                        description: nil,
                        defaultRange: PinLoadedMachineRange(
                            id: UUID().uuidString,
                            minWeight: 0,
                            maxWeight: 300,
                            increment: 5,
                            unit: .pounds,
                            isActive: true
                        ),
                        ranges: [
                            PinLoadedMachineRange(
                                id: UUID().uuidString,
                                minWeight: 0,
                                maxWeight: 300,
                                increment: 5,
                                unit: .pounds,
                                isActive: true
                            )
                        ],
                        isActive: false
                    )
                ]
            )
        ]
    }
}

extension GymProfileModel {
    var activeEquipmentCount: Int {
        freeWeights.filter(\.isActive).count
            + loadableBars.filter(\.isActive).count
            + supportEquipment.filter(\.isActive).count
            + cableMachines.filter(\.isActive).count
            + plateLoadedMachines.filter(\.isActive).count
            + pinLoadedMachines.filter(\.isActive).count
    }
}
