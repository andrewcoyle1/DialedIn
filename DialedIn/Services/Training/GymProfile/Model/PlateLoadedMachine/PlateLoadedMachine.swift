//
//  PlateLoadedMachine.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

struct PlateLoadedMachine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultBaseWeightId: String?
    var baseWeights: [PlateLoadedMachineRange]
    
    var defaultBaseWeight: PlateLoadedMachineRange? {
        baseWeights.first(where: { $0.id == self.defaultBaseWeightId })
    }
    
    var isActive: Bool
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        defaultBaseWeightId: String?,
        baseWeights: [PlateLoadedMachineRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultBaseWeightId = defaultBaseWeightId
        self.baseWeights = baseWeights
        self.isActive = isActive
    }
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        baseWeights: [PlateLoadedMachineRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultBaseWeightId = baseWeights.first?.id
        self.baseWeights = baseWeights
        self.isActive = isActive
    }
    
    static var defaultPlateLoadedMachines: [PlateLoadedMachine] = [
        PlateLoadedMachine(
            id: UUID().uuidString,
            name: "Ab Coaster Machine",
            description: nil,
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
    ]
    
    static var mock: PlateLoadedMachine {
        mocks[0]
    }
    
    static var mocks: [PlateLoadedMachine] = [
        PlateLoadedMachine(
            id: UUID().uuidString,
            name: "Ab Coaster Machine",
            description: nil,
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
    ]
}

struct PlateLoadedMachineRange: Identifiable, Codable {
    var id: String
    
    var baseWeight: Double
    var unit: ExerciseWeightUnit

    var isActive: Bool
}
