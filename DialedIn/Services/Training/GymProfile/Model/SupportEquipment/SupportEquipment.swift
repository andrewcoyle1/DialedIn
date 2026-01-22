//
//  SupportEquipment.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

struct SupportEquipment: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    
    var isActive: Bool
    
    static var defaultSupportEquipment: [SupportEquipment] = [
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
    ]
    
    static var mock: SupportEquipment {
        mocks[0]
    }
    
    static var mocks: [SupportEquipment] = [
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
    ]

}
