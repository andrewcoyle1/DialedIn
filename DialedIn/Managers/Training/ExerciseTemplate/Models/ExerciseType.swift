//
//  ExerciseType.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/01/2026.
//

enum ExerciseType: String, CaseIterable, Equatable, Codable, PickableItem {
    case compoundUpper
    case compoundLower
    case isolationUpper
    case isolationLower
    case core
    
    var name: String {
        switch self {
        case .compoundUpper: return "Upper Compound"
        case .compoundLower: return "Lower Compound"
        case .isolationUpper: return "Upper Isolation"
        case .isolationLower: return "Lower Isolation"
        case .core: return "Core"
        }
    }
    
    var description: String? {
        nil
    }
}

enum Laterality: String, CaseIterable, Codable, PickableItem {
    case bilateral
    case unilateral
    case assymetrical
    case unilateralBilateral
    
    var name: String {
        switch self {
        case .bilateral: return "Bilateral"
        case .unilateral: return "Unilateral"
        case .assymetrical: return "Asymmetrical"
        case .unilateralBilateral: return "Unilateral & Bilateral"
        }
    }
    
    var description: String? {
        switch self {
        case .bilateral: return "Both sides of the body work together at the same time."
        case .unilateral: return "Only one side of the body works independently at a time."
        case .assymetrical: return "Both sides work together, but with uneven load or position."
        case .unilateralBilateral: return "Exercises performed with both sides at once, but each limb works independently on its own path."
        }
    }
}

enum TrackableExerciseMetric: String, CaseIterable, Codable, PickableItem {
    case reps
    case repsPerSide
    case weight
    case weightPerSide
    case weightPerSidePersistent
    case weightPerSideAssistance
    case duration
    case durationPerSide
    case distanceShort
    case distanceShortPerSide
    case distanceLong
    
    var name: String {
        switch self {
        case .reps: return "Reps"
        case .repsPerSide: return "Reps Per Side"
        case .weight: return "Weight"
        case .weightPerSide: return "Weight Per Side"
        case .weightPerSidePersistent: return "Weight Per Side (Persistent)"
        case .weightPerSideAssistance: return "Weight Per Side (Assistance)"
        case .duration: return "Duration"
        case .durationPerSide: return "Duration Per Side"
        case .distanceShort: return "Distance Short"
        case .distanceShortPerSide: return "Distance Short Per Side"
        case .distanceLong: return "Distance Long"  
        }
    }

    var description: String? {
        switch self {
        case .reps: return "Track the number of repetitions performed."
        case .repsPerSide: return "Track the number of repetitions performed per side."
        case .weight: return "Track the load used for each set."
        case .weightPerSide: return "Track the load used for each set per side."
        case .weightPerSidePersistent: return "Track singular weight used on both sides."
        case .weightPerSideAssistance: return "Track assisted or supported weight."
        case .duration: return "Track time for each set."
        case .durationPerSide: return "Track time for each set per side."
        case .distanceShort: return "Track short distances, like sprints or carries."
        case .distanceShortPerSide: return "Track short distances per side."
        case .distanceLong: return "Track long distances, like runs or rows."
        }
    }
}

enum Muscles: String, CaseIterable, Codable {
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

enum BodyRegion: String, CaseIterable, Codable {
    case upperBody, lowerBody
    
    var name: String {
        switch self {
        case .upperBody: return "Upper Body"
        case .lowerBody: return "Lower Body"
        }
    }
}
