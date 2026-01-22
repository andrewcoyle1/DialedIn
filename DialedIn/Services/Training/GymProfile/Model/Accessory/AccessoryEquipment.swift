//
//  AccessoryEquipment.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

struct AccessoryEquipment: Identifiable, Codable {
    var id: String
    var name: String
    var imageName: String?

    var description: String?
    
    var isActive: Bool
    
    init(
        id: String,
        name: String,
        imageName: String? = nil,
        description: String? = nil,
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.description = description
        self.isActive = isActive
    }
    
    static var defaultAccessoryEquipment: [AccessoryEquipment] = [
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Ab Wheel",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Aerobic Steps",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Anchor Point For Elastic Band",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Anchor Point For Suspension Trainer",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Bench Press Board/Block",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Calf Raise Block",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Cuff Cable Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Deadlift Blocks",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Gymnastics Rings",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Landmine Attachment/Wall Corner",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Neutral Grip Landmine Row Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Nordic Hamstring Curl Strap",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Overhand Grip Landmine Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Plyometric Boxes",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Pull-Up Bar",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Push-Up Handles",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Slant Board",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Slingshot",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Split Squat Roller Stand",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Squat Box",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Stability Ball",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Staircase",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Suspension Trainer",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "V-Bar Row Grip Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Yoga Blocks",
            description: nil,
            isActive: true
        )
    ]
    
    static var mock: AccessoryEquipment {
        mocks[0]
    }
    
    static var mocks: [AccessoryEquipment] = [
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Ab Wheel",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Aerobic Steps",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Anchor Point For Elastic Band",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Anchor Point For Suspension Trainer",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Bench Press Board/Block",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Calf Raise Block",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Cuff Cable Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Deadlift Blocks",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Gymnastics Rings",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Landmine Attachment/Wall Corner",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Neutral Grip Landmine Row Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Nordic Hamstring Curl Strap",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Plyometric Boxes",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Pull-Up Bar",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Push-Up Handles",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Slant Board",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Slingshot",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Split Squat Roller Stand",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Squat Box",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Stability Ball",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Staircase",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Suspension Trainer",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "V-Bar Row Grip Attachment",
            description: nil,
            isActive: true
        ),
        AccessoryEquipment(
            id: UUID().uuidString,
            name: "Yoga Blocks",
            description: nil,
            isActive: true
        )
    ]
}
