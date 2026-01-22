//
//  PinLoadedMachine.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

struct PinLoadedMachine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var defaultRangeId: String?
    var ranges: [PinLoadedMachineRange]
    
    var defaultRange: PinLoadedMachineRange? {
        ranges.first(where: { $0.id == self.defaultRangeId } )
    }

    var isActive: Bool
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        ranges: [PinLoadedMachineRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultRangeId = ranges.first?.id
        self.ranges = ranges
        self.isActive = isActive
    }
    
    static var defaultPinLoadedMachines: [PinLoadedMachine] = [
        PinLoadedMachine(
            id: UUID().uuidString,
            name: "Biceps Curl Machine With Arms At Side",
            description: nil,
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
    
    static var mock: PinLoadedMachine {
        mocks[0]
    }
    
    static var mocks: [PinLoadedMachine] = [
        PinLoadedMachine(
            id: UUID().uuidString,
            name: "Biceps Curl Machine With Arms At Side",
            description: nil,
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
            ranges: [
                PinLoadedMachineRange(
                    id: UUID().uuidString,
                    name: "Range 1",
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
}

struct PinLoadedMachineRange: Identifiable, Codable, @MainActor WeightRange {
    var id: String
    var name: String
    
    var minWeight: Double
    var maxWeight: Double
    var increment: Double
    
    var unit: ExerciseWeightUnit

    var isActive: Bool
}
