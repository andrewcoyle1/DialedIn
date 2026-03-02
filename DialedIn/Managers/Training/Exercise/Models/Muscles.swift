//
//  Muscles.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/02/2026.
//

import Foundation

enum Muscles: String, CodingKeyRepresentable, CaseIterable, DataSyncModelProtocol {
    
    var id: String { self.rawValue }
    
    case triceps, upperTraps, obliques, neck, lats, forearms, sideDelts, rearDelts, frontDelts, chest, biceps, upperBack, lowerBack, abs, serratus
    case quads, hamstrings, glutes, calves, abductors, adductors, tibialis
    
    var name: String {
        switch self {
        case .triceps: return "Triceps"
        case .upperTraps: return "Upper Traps"
        case .obliques: return "Obliques"
        case .neck: return "Neck"
        case .lats: return "Lats"
        case .forearms: return "Forearms"
        case .sideDelts: return "Side Delts"
        case .rearDelts: return "Rear Delts"
        case .frontDelts: return "Front Delts"
        case .chest: return "Chest"
        case .biceps: return "Biceps"
        case .upperBack: return "Upper Back"
        case .lowerBack: return "Lower Back"
        case .abs: return "Abs"
        case .serratus: return "Serratus"
        case .quads: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .glutes: return "Glutes"
        case .calves: return "Calves"
        case .abductors: return "Abductors"
        case .adductors: return "Adductors"
        case .tibialis: return "Tibialis"
        }
    }

    var bodyRegion: BodyRegion {
        switch self {
        case .triceps, .upperTraps, .obliques, .neck, .lats, .forearms, .sideDelts, .rearDelts, .frontDelts, .chest, .biceps, .upperBack, .lowerBack, .abs, .serratus:
            return .upperBody
        case .quads, .hamstrings, .glutes, .calves, .abductors, .adductors, .tibialis:
            return .lowerBody
        }
    }
}
