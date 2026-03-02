//
//  TrackableExerciseMetric.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/02/2026.
//

import Foundation

enum TrackableExerciseMetric: String, DataSyncModelProtocol, PickableItem {
    
    var id: String { self.rawValue }
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
