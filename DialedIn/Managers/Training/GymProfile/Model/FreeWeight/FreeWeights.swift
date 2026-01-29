//
//  FreeWeights.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import SwiftUI

struct FreeWeights: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var imageName: String?
    var description: String?
    var needsColour: Bool
    var range: [FreeWeightsAvailable]
    
    var isActive: Bool
    
    init(
        id: String,
        name: String,
        imageName: String? = nil,
        description: String? = nil,
        needsColour: Bool,
        range: [FreeWeightsAvailable],
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.needsColour = needsColour
        self.range = range
        self.isActive = isActive
    }

    nonisolated static func == (lhs: FreeWeights, rhs: FreeWeights) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static var defaultFreeWeights: [FreeWeights] = [
        FreeWeights(
            id: "bumper_plates",
            name: "Bumper Plates",
            imageName: "bumper_plates_icon",
            description: nil,
            needsColour: true,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    plateColour: Color.gray.asHex(),
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: true
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
                    isActive: true
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
                    isActive: true
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
                    isActive: true
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
                    isActive: true
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: "dumbbells",
            name: "Dumbbells",
            imageName: "dumbbells_icon",
            description: nil,
            needsColour: false,
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
            id: "kettlebells",
            name: "Kettlebells",
            imageName: "kettlebells_icon",
            description: nil,
            needsColour: false,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 4,
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
                    availableWeights: 8,
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
                    availableWeights: 14,
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
                    availableWeights: 24,
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
                    availableWeights: 36,
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
                    availableWeights: 44,
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
                    availableWeights: 52,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 56,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 60,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 64,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 68,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 72,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 76,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 80,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 84,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 92,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 5,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 9,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 13,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 15,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 18,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 26,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 30,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 35,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 40,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 44,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 45,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 50,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 53,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 62,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 70,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 80,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 97,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 106,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 124,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 150,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 176,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 203,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: "medicine_ball",
            name: "Medicine Ball",
            imageName: "medicine_ball_icon",
            description: nil,
            needsColour: false,
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
                    availableWeights: 4,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 6,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 8,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 12,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 14,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 16,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 18,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 30,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: "weight_plates",
            name: "Weight Plates",
            imageName: "weight_plates_icon",
            description: nil,
            needsColour: true,
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

    static var mock: FreeWeights {
        mocks[0]
    }
    
    static var mocks: [FreeWeights] = [
        FreeWeights(
            id: "bumper_plates",
            name: "Bumper Plates",
            imageName: "bumper_plates_icon",
            description: nil,
            needsColour: true,
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
            id: "dumbbells",
            name: "Dumbbells",
            imageName: "dumbbells_icon",
            description: nil,
            needsColour: false,
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
            id: "kettlebells",
            name: "Kettlebells",
            imageName: "kettlebells_icon",
            description: nil,
            needsColour: false,
            range: [
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 4,
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
                    availableWeights: 8,
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
                    availableWeights: 14,
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
                    availableWeights: 24,
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
                    availableWeights: 36,
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
                    availableWeights: 44,
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
                    availableWeights: 52,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 56,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 60,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 64,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 68,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 72,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 76,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 80,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 84,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 92,
                    unit: .kilograms,
                    isActive: true
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 5,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 9,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 13,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 15,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 18,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 26,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 30,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 35,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 40,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 44,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 45,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 50,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 53,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 62,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 70,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 80,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 88,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 97,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 106,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 124,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 150,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 176,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 203,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),
        FreeWeights(
            id: "medicine_ball",
            name: "Medicine Ball",
            imageName: "medicine_ball_icon",
            description: nil,
            needsColour: false,
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
                    availableWeights: 4,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 6,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 8,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 10,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 12,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 14,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 16,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 18,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 20,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 25,
                    unit: .pounds,
                    isActive: false
                ),
                FreeWeightsAvailable(
                    id: UUID().uuidString,
                    availableWeights: 30,
                    unit: .pounds,
                    isActive: false
                )
            ],
            isActive: true
        ),

        FreeWeights(
            id: "weight_plates",
            name: "Weight Plates",
            imageName: "weight_plates_icon",
            description: nil,
            needsColour: true,
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
}

struct FreeWeightsAvailable: Identifiable, Codable {
    var id: String
    
    var plateColour: String?
    var availableWeights: Double
    var unit: ExerciseWeightUnit
    
    var isActive: Bool
}
