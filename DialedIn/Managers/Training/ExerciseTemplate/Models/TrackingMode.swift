//
//  TrackingMode.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/01/2026.
//

import Foundation

enum TrackingMode: String, Codable, CaseIterable, Hashable {
    case weightReps
    case repsOnly
    case timeOnly
    case distanceTime
}
