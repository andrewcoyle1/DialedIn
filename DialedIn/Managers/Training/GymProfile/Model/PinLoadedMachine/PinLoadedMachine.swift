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
    var imageName: String?
    var description: String?
    var defaultRangeId: String?
    var ranges: [PinLoadedMachineRange]
    
    var defaultRange: PinLoadedMachineRange? {
        ranges.first(where: { $0.id == self.defaultRangeId })
    }

    var isActive: Bool
    
    init(
        id: String,
        name: String,
        imageName: String? = nil,
        description: String? = nil,
        ranges: [PinLoadedMachineRange],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.defaultRangeId = ranges.first?.id
        self.ranges = ranges
        self.isActive = isActive
    }
    
    static var defaultPinLoadedMachines: [PinLoadedMachine] = [
        PinLoadedMachine(
            id: "biceps_curl_machine_with_arms_at_side",
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
            id: "chest-supported_pin-loaded_row_machine",
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
            id: "kneeling_lower_trunk_rotation_machine",
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
            id: "kneeling_pin-loaded_glute_kickback_machine",
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
            id: "lying_pin-loaded_chest_press_machine",
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
            id: "lying_pin-loaded_leg_curl_machine",
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
            id: "pin-loaded_row_machine_without_chest_support",
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
            id: "pin-loaded_shoulder_press_machine",
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
            id: "pin-loaded_tricep_extension_machine",
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
            id: "reclined_pin-loaded_incline_press_machine",
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
            id: "seated_lower_trunk_rotation_machine",
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
            id: "seated_pin-loaded_calf_raise_machine",
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
            id: "seated_pin-loaded_chest_press_machine",
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
            id: "seated_pin-loaded_hip_abduction_machine",
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
            id: "seated_pin-loaded_hip_abduction_adduction_combo_machine",
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
            id: "seated_pin-loaded_hip_adduction_machine",
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
            id: "seated_pin-loaded_incline_press_machine",
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
            id: "seated_pin-loaded_lateral_raise_machine",
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
            id: "seated_pin-loaded_leg_curl_machine",
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
            id: "seated_pin-loaded_shrug_machine",
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
            id: "standing_pin-loaded_calf_raise_machine",
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
            id: "standing_pin-loaded_glute_kickback_machine",
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
            id: "standing_pin-loaded_lateral_raise_machine",
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
            id: "standing_pin-loaded_leg_curl_machine",
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
            id: "upper_trunk_rotation_machine_with_arm_or_shoulder_pads",
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
            id: "upper_trunk_rotation_machine_with_chest_pad",
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
            id: "biceps_curl_machine_with_arms_at_side",
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
            id: "chest-supported_pin-loaded_row_machine",
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
            id: "kneeling_lower_trunk_rotation_machine",
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
            id: "kneeling_pin-loaded_glute_kickback_machine",
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
            id: "lying_pin-loaded_chest_press_machine",
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
            id: "lying_pin-loaded_leg_curl_machine",
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
            id: "pin-loaded_row_machine_without_chest_support",
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
            id: "pin-loaded_shoulder_press_machine",
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
            id: "pin-loaded_tricep_extension_machine",
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
            id: "pin-loaded_abdominal_crunch_machine_with_front_handles",
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
            id: "pin-loaded_abdominal_crunch_machine_with_overhead_handles",
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
            id: "pin-loaded_assisted_pull-up_dip_machine",
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
            id: "pin-loaded_back_extension_machine",
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
            id: "pin-loaded_chest_fly_machine_with_arm_pads",
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
            id: "pin-loaded_dip_machine",
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
            id: "pin-loaded_hip_thrust_machine",
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
            id: "pin-loaded_leg_extension_machine",
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
            id: "pin-loaded_leg_press_machine",
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
            id: "pin-loaded_overhead_triceps_extension_machine",
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
            id: "pin-loaded_preacher_curl_machine",
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
            id: "pin-loaded_preacher_curl_triceps_extension_combo_machine",
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
            id: "pin-loaded_pulldown_machine",
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
            id: "pin-loaded_pullover_machine",
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
            id: "pin-loaded_reverse_hyperextension_machine",
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
            id: "pin-loaded_row_machine_without_chest_support",
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
            id: "pin-loaded_shoulder_press_machine",
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
            id: "pin-loaded_tricep_extension_machine",
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
            id: "reclined_pin-loaded_incline_press_machine",
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
            id: "seated_lower_trunk_rotation_machine",
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
            id: "seated_pin-loaded_calf_raise_machine",
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
            id: "seated_pin-loaded_chest_press_machine",
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
            id: "seated_pin-loaded_hip_abduction_machine",
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
            id: "seated_pin-loaded_hip_abduction_adduction_combo_machine",
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
            id: "seated_pin-loaded_hip_adduction_machine",
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
            id: "seated_pin-loaded_incline_press_machine",
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
            id: "seated_pin-loaded_lateral_raise_machine",
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
            id: "seated_pin-loaded_leg_curl_machine",
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
            id: "seated_pin-loaded_shrug_machine",
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
            id: "standing_pin-loaded_calf_raise_machine",
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
            id: "standing_pin-loaded_glute_kickback_machine",
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
            id: "standing_pin-loaded_lateral_raise_machine",
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
            id: "standing_pin-loaded_leg_curl_machine",
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
            id: "upper_trunk_rotation_machine_with_arm_or_shoulder_pads",
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
            id: "upper_trunk_rotation_machine_with_chest_pad",
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
