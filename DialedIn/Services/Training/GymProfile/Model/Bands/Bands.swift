//
//  Bands.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI

struct Bands: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var range: [BandsAvailable]
    
    var isActive: Bool
    
    static var defaultBands: [Bands] = [
        Bands(
            id: UUID().uuidString,
            name: "Long Elastic Bands",
            description: nil,
            range: [
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 4,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 8,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 14,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 18,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 30,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 43,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Super Heavy Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 52,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heaviest Resistance",
                    bandColour: Color.gray.asHex(),
                    availableResistance: 102,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 9,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 18,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 30,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 40,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 65,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 95,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Super Heavy Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 115,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heaviest Resistance",
                    bandColour: Color.gray.asHex(),
                    availableResistance: 225,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),
        Bands(
            id: UUID().uuidString,
            name: "Short Elastic Bands",
            description: nil,
            range: [
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 4,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 8,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 14,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 18,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 30,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 43,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 9,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 18,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 30,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 40,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 65,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 95,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        )
    ]

    static var mock: Bands {
        mocks[0]
    }
    
    static var mocks: [Bands] = [
        Bands(
            id: UUID().uuidString,
            name: "Long Elastic Bands",
            description: nil,
            range: [
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 4,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 8,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 14,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 18,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 30,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 43,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Super Heavy Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 52,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heaviest Resistance",
                    bandColour: Color.gray.asHex(),
                    availableResistance: 102,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 9,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 18,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 30,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 40,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 65,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 95,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Super Heavy Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 115,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heaviest Resistance",
                    bandColour: Color.gray.asHex(),
                    availableResistance: 225,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),
        Bands(
            id: UUID().uuidString,
            name: "Short Elastic Bands",
            description: nil,
            range: [
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 4,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 8,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 14,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 18,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 30,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 43,
                    unit: .kilograms,
                    isActive: true
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Light Resistance",
                    bandColour: Color.orange.asHex(),
                    availableResistance: 9,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Light Resistance",
                    bandColour: Color.red.asHex(),
                    availableResistance: 18,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium Resistance",
                    bandColour: Color.blue.asHex(),
                    availableResistance: 30,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Medium-Heavy Resistance",
                    bandColour: Color.green.asHex(),
                    availableResistance: 40,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Heavy Resistance",
                    bandColour: Color.black.asHex(),
                    availableResistance: 65,
                    unit: .pounds,
                    isActive: false
                ),
                BandsAvailable(
                    id: UUID().uuidString,
                    name: "Extra Heavy Resistance",
                    bandColour: Color.purple.asHex(),
                    availableResistance: 95,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        )
    ]
}

struct BandsAvailable: Identifiable, Codable {
    var id: String
    
    var name: String
    var bandColour: String
    var availableResistance: Double
    var unit: ExerciseWeightUnit
    
    var isActive: Bool
}
